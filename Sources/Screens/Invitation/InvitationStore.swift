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
import VoltaserveCore

class InvitationStore: ObservableObject {
    @Published var entities: [VOInvitation.Entity]?
    @Published var entitiesError: String?
    @Published var entitiesIsLoading: Bool = false
    var entitiesIsLoadingFirstTime: Bool { entitiesIsLoading && entities == nil }
    @Published var incomingCount: Int?
    @Published var incomingCountError: String?
    @Published var incomingCountIsLoading: Bool = false
    private var list: VOInvitation.List?
    private var timer: Timer?
    private var invitationClient: VOInvitation?
    var organizationID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                invitationClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    // MARK: - Fetch

    private func fetchProbe(size: Int = Constants.pageSize) async throws -> VOInvitation.Probe? {
        if let organizationID {
            try await invitationClient?.fetchOutgoingProbe(.init(organizationID: organizationID, size: size))
        } else {
            try await invitationClient?.fetchIncomingProbe(.init(size: size))
        }
    }

    private func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOInvitation.List? {
        if let organizationID {
            try await invitationClient?.fetchOutgoingList(
                .init(organizationID: organizationID, page: page, size: size, sortBy: .dateCreated, sortOrder: .desc))
        } else {
            try await invitationClient?.fetchIncomingList(
                .init(page: page, size: size, sortBy: .dateCreated, sortOrder: .desc))
        }
    }

    func fetchNextPage(replace: Bool = false) {
        guard !entitiesIsLoading else { return }

        var nextPage = -1
        var list: VOInvitation.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.fetchProbe(size: Constants.pageSize)
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
            list = try await self.fetchList(page: nextPage)
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

    private func fetchIncomingCount() async throws -> Int? {
        try await invitationClient?.fetchIncomingCount()
    }

    func fetchIncomingCount() {
        var incomingCount: Int?
        withErrorHandling {
            incomingCount = try await self.fetchIncomingCount()
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

    func create(emails: [String]) async throws -> [VOInvitation.Entity]? {
        guard let organizationID else { return nil }
        return try await invitationClient?.create(.init(organizationID: organizationID, emails: emails))
    }

    func accept(_ id: String) async throws {
        try await invitationClient?.accept(id)
    }

    func decline(_ id: String) async throws {
        try await invitationClient?.decline(id)
    }

    func delete(_ id: String) async throws {
        try await invitationClient?.delete(id)
    }

    // MARK: - Entities

    func append(_ newEntities: [VOInvitation.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.id == newEntity.id }) {
            entities!.append(newEntity)
        }
    }

    func clear() {
        entities = nil
        list = nil
    }

    // MARK: - Paging

    func nextPage() -> Int {
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

    func hasNextPage() -> Bool {
        nextPage() != -1
    }

    func isEntityThreshold(_ id: String) -> Bool {
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

    // MARK: - Timer

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.entities != nil {
                Task {
                    var size = Constants.pageSize
                    if let list = self.list {
                        size = Constants.pageSize * list.page
                    }
                    let list = try await self.fetchList(page: 1, size: size)
                    if let list {
                        DispatchQueue.main.async {
                            self.entities = list.data
                            self.entitiesError = nil
                        }
                    }
                }
            }
            if self.incomingCount != nil {
                Task {
                    let incomingCount = try await self.fetchIncomingCount()
                    if let incomingCount {
                        DispatchQueue.main.async {
                            self.incomingCount = incomingCount
                            self.incomingCountError = nil
                        }
                    }
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 50
    }
}
