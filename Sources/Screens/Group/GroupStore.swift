// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import Foundation

@MainActor
public class GroupStore: ObservableObject {
    @Published public var entities: [VOGroup.Entity]?
    @Published public var entitiesIsLoading = false
    public var entitiesIsLoadingFirstTime: Bool { entitiesIsLoading && entities == nil }
    @Published public var entitiesError: String?
    @Published public var current: VOGroup.Entity?
    @Published public var currentIsLoading = false
    @Published public var currentError: String?
    @Published public var query: String?
    private var list: VOGroup.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var groupClient: VOGroup?
    public let searchPublisher = PassthroughSubject<String, Never>()
    public var organizationID: String?

    public var session: VOSession.Value? {
        didSet {
            if let session {
                groupClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
            }
        }
    }

    public init(organizationID: String? = nil) {
        self.organizationID = organizationID
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    public func fetchCurrent(_ id: String) {
        var group: VOGroup.Entity?
        withErrorHandling {
            group = try await self.groupClient?.fetch(id)
            return true
        } before: {
            self.currentIsLoading = true
        } success: {
            self.current = group
            self.currentError = nil
        } failure: { message in
            self.currentError = message
        } anyways: {
            self.currentIsLoading = false
        }
    }

    public func fetchNextPage(replace: Bool = false) {
        guard !entitiesIsLoading else { return }
        var nextPage = -1
        var list: VOGroup.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.groupClient?.fetchProbe(
                    .init(
                        query: self.query,
                        organizationID: self.organizationID,
                        size: Constants.pageSize
                    ))
                if let probe {
                    self.list = .init(
                        data: list.data,
                        totalPages: probe.totalPages,
                        totalElements: probe.totalElements,
                        page: list.page,
                        size: list.size
                    )
                }
            }
            if !self.hasNextPage() { return false }
            nextPage = self.nextPage()
            list = try await self.groupClient?.fetchList(
                .init(
                    query: self.query,
                    organizationID: self.organizationID,
                    page: nextPage,
                    size: Constants.pageSize,
                    sortBy: .dateCreated,
                    sortOrder: .desc
                )
            )
            return true
        } before: {
            self.entitiesIsLoading = true
        } success: {
            self.list = list
            if let list {
                if replace, nextPage == 1 {
                    self.entities = list.data
                } else {
                    self.append(list.data)
                }
            }
            self.entitiesError = nil
        } failure: { message in
            self.entitiesError = message
        } anyways: {
            self.entitiesIsLoading = false
        }
    }

    // MARK: - Update

    public func create(_ options: VOGroup.CreateOptions) async throws -> VOGroup.Entity? {
        try await groupClient?.create(options)
    }

    public func patchName(_ id: String, options: VOGroup.PatchNameOptions) async throws -> VOGroup.Entity? {
        try await groupClient?.patchName(id, options: options)
    }

    public func delete(_ id: String) async throws {
        try await groupClient?.delete(id)
    }

    public func addMember(_ id: String, options: VOGroup.AddMemberOptions) async throws {
        try await groupClient?.addMember(id, options: options)
    }

    public func removeMember(_ id: String, options: VOGroup.RemoveMemberOptions) async throws {
        try await groupClient?.removeMember(id, options: options)
    }

    // MARK: - Sync

    public func syncEntities() async throws {
        if let entities = await self.entities {
            let list = try await self.groupClient?.fetchList(
                .init(
                    query: query,
                    organizationID: organizationID,
                    page: 1,
                    size: entities.count > Constants.pageSize ? entities.count : Constants.pageSize,
                    sortBy: .dateCreated,
                    sortOrder: .desc
                )
            )
            if let list {
                await MainActor.run {
                    self.entities = list.data
                    self.entitiesError = nil
                }
            }
        }
    }

    public func syncCurrent() async throws {
        if let current = self.current {
            let group = try await self.groupClient?.fetch(current.id)
            if let group {
                try await syncCurrent(group: group)
            }
        }
    }

    public func syncCurrent(group: VOGroup.Entity) async throws {
        if let current = self.current {
            await MainActor.run {
                let index = entities?.firstIndex(where: { $0.id == current.id })
                if let index {
                    self.current = group
                    entities?[index] = group
                }
            }
        }
    }

    // MARK: - Entities

    public func append(_ newEntities: [VOGroup.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.id == newEntity.id }) {
            entities!.append(newEntity)
        }
    }

    public func clear() {
        entities = nil
        list = nil
    }

    // MARK: - Pagination

    public func nextPage() -> Int {
        var page = 1
        if let list {
            if list.page < list.totalPages {
                page = list.page + 1
            } else if list.page == list.totalPages {
                return -1
            }
        }
        return page
    }

    public func hasNextPage() -> Bool {
        nextPage() != -1
    }

    public func isEntityThreshold(_ id: String) -> Bool {
        if let entities {
            let threashold = Constants.pageSize / 2
            if entities.count >= threashold,
                entities.firstIndex(where: { $0.id == id }) == entities.count - threashold
            {
                return true
            } else {
                return id == entities.last?.id
            }
        }
        return false
    }

    public func isLastPage() -> Bool {
        if let list {
            return list.page == list.totalPages
        }
        return false
    }

    // MARK: - Timer

    public func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task.detached {
                try await self.syncEntities()
                try await self.syncCurrent()
            }
        }
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 50
    }
}
