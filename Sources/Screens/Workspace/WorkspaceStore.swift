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
// swiftlint:disable:next type_body_length
public class WorkspaceStore: ObservableObject {
    @Published public var entities: [VOWorkspace.Entity]?
    @Published public var entitiesIsLoading = false
    public var entitiesIsLoadingFirstTime: Bool { entitiesIsLoading && entities == nil }
    @Published public var entitiesError: String?
    @Published public var root: VOFile.Entity?
    @Published public var rootIsLoading = false
    @Published public var rootError: String?
    @Published public var storageUsage: VOStorage.Usage?
    @Published public var storageUsageIsLoading = false
    @Published public var storageUsageError: String?
    @Published public var current: VOWorkspace.Entity?
    @Published public var currentIsLoading = false
    @Published public var currentError: String?
    @Published public var query: String?
    private var list: VOWorkspace.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var workspaceClient: VOWorkspace?
    private var fileClient: VOFile?
    private var storageClient: VOStorage?
    let searchPublisher = PassthroughSubject<String, Never>()

    public var session: VOSession.Value? {
        didSet {
            if let session {
                workspaceClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
                fileClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
                storageClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
            }
        }
    }

    public init() {
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
        var workspace: VOWorkspace.Entity?
        var root: VOFile.Entity?

        withErrorHandling {
            workspace = try await self.workspaceClient?.fetch(id)
            if let workspace {
                root = try await self.fileClient?.fetch(workspace.rootID)
            }
            return true
        } before: {
            self.currentIsLoading = true
            self.rootIsLoading = true
        } success: {
            self.current = workspace
            self.currentError = nil

            self.root = root
            self.rootError = nil
        } failure: { message in
            self.currentError = message
            self.rootError = message
        } anyways: {
            self.currentIsLoading = false
            self.rootIsLoading = false
        }
    }

    public func fetchNextPage(replace: Bool = false) {
        guard !entitiesIsLoading else { return }
        var nextPage = -1
        var list: VOWorkspace.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.workspaceClient?.fetchProbe(
                    .init(
                        query: self.query,
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
            list = try await self.workspaceClient?.fetchList(
                .init(
                    query: self.query,
                    page: nextPage,
                    size: Constants.pageSize,
                    sortBy: .dateCreated,
                    sortOrder: .desc
                ))
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

    public func fetchStorageUsage() {
        guard let current else { return }
        var storageUsage: VOStorage.Usage?

        withErrorHandling {
            storageUsage = try await self.storageClient?.fetchWorkspaceUsage(current.id)
            return true
        } before: {
            self.storageUsageIsLoading = true
        } success: {
            self.storageUsage = storageUsage
            self.storageUsageError = nil
        } failure: { message in
            self.storageUsageError = message
        } anyways: {
            self.storageUsageIsLoading = false
        }
    }

    // MARK: - Update

    public func create(_ options: VOWorkspace.CreateOptions) async throws -> VOWorkspace.Entity? {
        try await workspaceClient?.create(options)
    }

    public func patchName(_ id: String, options: VOWorkspace.PatchNameOptions) async throws -> VOWorkspace.Entity? {
        try await workspaceClient?.patchName(id, options: options)
    }

    public func patchStorageCapacity(
        _ id: String,
        options: VOWorkspace.PatchStorageCapacityOptions
    ) async throws -> VOWorkspace.Entity? {
        return try await workspaceClient?.patchStorageCapacity(id, options: options)
    }

    public func delete(_ id: String) async throws {
        try await workspaceClient?.delete(id)
    }

    // MARK: - Sync

    public func syncEntities() async throws {
        if let entities = await self.entities {
            let list = try await self.workspaceClient?.fetchList(
                .init(
                    query: self.query,
                    page: 1,
                    size: entities.count > Constants.pageSize ? entities.count : Constants.pageSize,
                    sortBy: .dateCreated,
                    sortOrder: .desc
                ))
            if let list {
                await MainActor.run {
                    self.entities = list.data
                    self.entitiesError = nil
                }
            }
        }
    }

    public func syncRoot() async throws {
        if let current = await current, await root != nil {
            let root = try await self.fileClient?.fetch(current.rootID)
            if let root {
                await MainActor.run {
                    self.root = root
                    self.rootError = nil
                }
            }
        }
    }

    public func syncStorageUsage() async throws {
        if let current = await current, await storageUsage != nil {
            let storageUsage = try await self.storageClient?.fetchWorkspaceUsage(current.id)
            if let storageUsage {
                await MainActor.run {
                    self.storageUsage = storageUsage
                    self.storageUsageError = nil
                }
            }
        }
    }

    public func syncCurrent() async throws {
        if let current = self.current {
            let workspace = try await self.workspaceClient?.fetch(current.id)
            if let workspace {
                try await syncCurrent(workspace: workspace)
            }
        }
    }

    public func syncCurrent(workspace: VOWorkspace.Entity) async throws {
        if let current = self.current {
            await MainActor.run {
                let index = entities?.firstIndex(where: { $0.id == workspace.id })
                if let index {
                    self.current = workspace
                    self.entities?[index] = workspace
                }
            }
        }
    }

    // MARK: - Entities

    public func append(_ newEntities: [VOWorkspace.Entity]) {
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
                try await self.syncRoot()
                try await self.syncStorageUsage()
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
