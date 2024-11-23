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

class SnapshotStore: ObservableObject {
    @Published var entities: [VOSnapshot.Entity]?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    private var list: VOSnapshot.List?
    private var timer: Timer?
    private var snapshotClient: VOSnapshot?
    var fileID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                snapshotClient = VOSnapshot(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    // MARK: - Fetch

    private func fetch(id: String) async throws -> VOSnapshot.Entity? {
        try await snapshotClient?.fetch(id)
    }

    private func fetchProbe(size: Int = Constants.pageSize) async throws -> VOSnapshot.Probe? {
        guard let fileID else { return nil }
        return try await snapshotClient?.fetchProbe(.init(fileID: fileID, size: size, sortOrder: .desc))
    }

    private func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOSnapshot.List? {
        guard let fileID else { return nil }
        return try await snapshotClient?.fetchList(.init(
            fileID: fileID,
            page: page,
            size: size,
            sortBy: .version,
            sortOrder: .desc
        ))
    }

    func fetchNextPage(replace: Bool = false) {
        guard !isLoading else { return }

        var nextPage = -1
        var list: VOSnapshot.List?

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
            self.isLoading = true
        } success: {
            self.list = list
            if let list {
                if replace, nextPage == 1 {
                    self.entities = list.data
                } else {
                    self.append(list.data)
                }
            }
        } failure: { message in
            self.errorTitle = "Error: Fetching Snapshots"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    // MARK: - Update

    func activate(_ id: String) async throws {
        try await snapshotClient?.activate(id)
    }

    func detach(_ id: String) async throws {
        try await snapshotClient?.detach(id)
    }

    // MARK: - Entities

    func append(_ newEntities: [VOSnapshot.Entity]) {
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
               entities.firstIndex(where: { $0.id == id }) == entities.count - threashold {
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
            Task {
                var size = Constants.pageSize
                if let list = self.list {
                    size = Constants.pageSize * list.page
                }
                let list = try await self.fetchList(page: 1, size: size)
                if let list {
                    DispatchQueue.main.async {
                        self.entities = list.data
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
        static let pageSize: Int = 50
    }
}
