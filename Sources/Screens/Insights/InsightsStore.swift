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
public class InsightsStore: ObservableObject {
    @Published public var entities: [VOEntity.Entity]?
    @Published public var entitiesIsLoading = false
    public var entitiesIsLoadingFirstTime: Bool { entitiesIsLoading && entities == nil }
    @Published public var entitiesError: String?
    @Published public var languages: [VOSnapshot.Language]?
    @Published public var languagesIsLoading = false
    public var languagesIsLoadingFirstTime: Bool { languagesIsLoading && languages == nil }
    @Published public var languagesError: String?
    @Published public var query: String?
    private var list: VOEntity.List?
    private var cancellables: Set<AnyCancellable> = []
    private var timer: Timer?
    private var entityClient: VOEntity?
    private var snapshotClient: VOSnapshot?

    public let searchPublisher = PassthroughSubject<String, Never>()
    public var file: VOFile.Entity?
    public var pageSize: Int?

    public var session: VOSession.Value? {
        didSet {
            if let session {
                entityClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
                snapshotClient = .init(
                    baseURL: Config.shared.apiURL,
                    accessKey: session.accessKey
                )
            }
        }
    }

    public init(file: VOFile.Entity? = nil, pageSize: Int? = nil) {
        self.file = file
        self.pageSize = pageSize
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    public func fetchLanguages() {
        var languages: [VOSnapshot.Language]?
        withErrorHandling {
            languages = try await self.snapshotClient?.fetchLanguages()
            return true
        } before: {
            self.languagesIsLoading = true
        } success: {
            self.languages = languages
            self.languagesError = nil
        } failure: { message in
            self.languagesError = message
        } anyways: {
            self.languagesIsLoading = false
        }
    }

    public func fetchEntityNextPage(replace: Bool = false) {
        guard !entitiesIsLoading else { return }
        var nextPage = -1
        var list: VOEntity.List?

        withErrorHandling {
            if let list = self.list, let file = self.file {
                let probe = try await self.entityClient?.fetchProbe(
                    file.id,
                    options: .init(
                        query: self.query,
                        size: self.pageSize ?? Constants.pageSize,
                        sortBy: .frequency,
                        sortOrder: .desc
                    )
                )
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
            if let file = self.file {
                list = try await self.entityClient?.fetchList(
                    file.id,
                    options: .init(
                        query: self.query,
                        page: nextPage,
                        size: self.pageSize ?? Constants.pageSize,
                        sortBy: .frequency,
                        sortOrder: .desc
                    )
                )
            }
            self.entitiesError = nil
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
        } failure: { message in
            self.entitiesError = message
        } anyways: {
            self.entitiesIsLoading = false
        }
    }

    // MARK: - Update

    public func create(_ id: String, options: VOEntity.CreateOptions) async throws -> VOTask.Entity? {
        try await entityClient?.create(id, options: options)
    }

    public func delete(_ id: String) async throws -> VOTask.Entity? {
        try await entityClient?.delete(id)
    }

    // MARK: - Sync

    public func syncEntities() async throws {
        if let entities = await self.entities, let file = self.file {
            let list = try await self.entityClient?.fetchList(
                file.id,
                options: .init(
                    query: self.query,
                    page: 1,
                    size: entities.count > Constants.pageSize ? entities.count : Constants.pageSize,
                    sortBy: .frequency,
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

    // MARK: - Entities

    public func append(_ newEntities: [VOEntity.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.text == newEntity.text }) {
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

    // MARK: - Timer

    public func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task.detached {
                try await self.syncEntities()
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
