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
public class InvitationStore: ObservableObject {
    @Published public var entities: [VOInvitation.Entity]?
    @Published public var entitiesError: String?
    @Published public var entitiesIsLoading = false
    public var entitiesIsLoadingFirstTime: Bool { entitiesIsLoading && entities == nil }
    @Published public var incomingCount: Int?
    @Published public var incomingCountError: String?
    @Published public var incomingCountIsLoading = false
    private var list: VOInvitation.List?
    private var timer: Timer?
    private var invitationClient: VOInvitation?
    public var organizationID: String?

    public init() {}

    public var session: VOSession.Value? {
        didSet {
            if let session {
                invitationClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
            }
        }
    }

    // MARK: - Fetch

    public func fetchNextPage(replace: Bool = false) {
        guard !entitiesIsLoading else { return }
        var nextPage = -1
        var list: VOInvitation.List?

        withErrorHandling {
            if let list = self.list {
                var probe: VOInvitation.Probe?
                if let organizationID = self.organizationID {
                    probe = try await self.invitationClient?.fetchOutgoingProbe(
                        .init(
                            organizationID: organizationID,
                            size: Constants.pageSize
                        )
                    )
                } else {
                    probe = try await self.invitationClient?.fetchIncomingProbe(
                        .init(size: Constants.pageSize)
                    )
                }
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
            if let organizationID = self.organizationID {
                list = try await self.invitationClient?.fetchOutgoingList(
                    .init(
                        organizationID: organizationID,
                        page: nextPage,
                        size: Constants.pageSize,
                        sortBy: .dateCreated,
                        sortOrder: .desc
                    ))
            } else {
                list = try await self.invitationClient?.fetchIncomingList(
                    .init(
                        page: nextPage,
                        size: Constants.pageSize,
                        sortBy: .dateCreated,
                        sortOrder: .desc
                    ))
            }
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

    public func fetchIncomingCount() {
        var incomingCount: Int?
        withErrorHandling {
            incomingCount = try await self.invitationClient?.fetchIncomingCount()
            return true
        } before: {
            self.incomingCountIsLoading = true
        } success: {
            self.incomingCount = incomingCount
            self.incomingCountError = nil
        } failure: { message in
            self.incomingCountError = message
        } anyways: {
            self.incomingCountIsLoading = false
        }
    }

    // MARK: - Update

    public func create(_ options: VOInvitation.CreateOptions) async throws -> [VOInvitation.Entity]? {
        return try await invitationClient?.create(options)
    }

    public func accept(_ id: String) async throws {
        try await invitationClient?.accept(id)
    }

    public func decline(_ id: String) async throws {
        try await invitationClient?.decline(id)
    }

    public func delete(_ id: String) async throws {
        try await invitationClient?.delete(id)
    }

    // MARK: - Sync

    public func syncEntities() async throws {
        if let entities = await self.entities {
            var list: VOInvitation.List?
            if let organizationID {
                list = try await invitationClient?.fetchOutgoingList(
                    .init(
                        organizationID: organizationID,
                        page: 1,
                        size: entities.count > Constants.pageSize ? entities.count : Constants.pageSize,
                        sortBy: .dateCreated,
                        sortOrder: .desc
                    ))
            } else {
                list = try await invitationClient?.fetchIncomingList(
                    .init(
                        page: 1,
                        size: entities.count > Constants.pageSize ? entities.count : Constants.pageSize,
                        sortBy: .dateCreated,
                        sortOrder: .desc
                    ))
            }
            if let list {
                await MainActor.run {
                    self.entities = list.data
                    self.entitiesError = nil
                }
            }
        }
    }

    public func syncIncomingCount() async throws {
        if await incomingCount != nil {
            let incomingCount = try await self.invitationClient?.fetchIncomingCount()
            if let incomingCount {
                DispatchQueue.main.async {
                    self.incomingCount = incomingCount
                    self.incomingCountError = nil
                }
            }
        }
    }

    // MARK: - Entities

    public func append(_ newEntities: [VOInvitation.Entity]) {
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
                try await self.syncIncomingCount()
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
