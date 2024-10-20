import Combine
import Foundation
import VoltaserveCore

class GroupStore: ObservableObject {
    @Published var entities: [VOGroup.Entity]?
    @Published var current: VOGroup.Entity?
    @Published var query: String?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isLoading = false
    private var list: VOGroup.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var groupClient: VOGroup?
    let searchPublisher = PassthroughSubject<String, Never>()
    var organizationID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                groupClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    init(organizationID: String? = nil) {
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

    private func fetch(_ id: String) async throws -> VOGroup.Entity? {
        try await groupClient?.fetch(id)
    }

    private func fetchProbe(size: Int = Constants.pageSize) async throws -> VOGroup.Probe? {
        if let organizationID {
            try await groupClient?.fetchProbe(.init(
                query: query,
                organizationID: organizationID,
                size: size
            ))
        } else {
            try await groupClient?.fetchProbe(.init(
                query: query,
                size: size
            ))
        }
    }

    private func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOGroup.List? {
        if let organizationID {
            try await groupClient?.fetchList(.init(
                query: query,
                organizationID: organizationID,
                page: page,
                size: size
            ))
        } else {
            try await groupClient?.fetchList(.init(
                query: query,
                page: page,
                size: size
            ))
        }
    }

    func fetchNext(replace: Bool = false) {
        guard !isLoading else { return }

        var nextPage = -1
        var list: VOGroup.List?

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
            self.errorTitle = "Error: Fetching Groups"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    // MARK: - Update

    func create(name: String, organization: VOOrganization.Entity) async throws -> VOGroup.Entity? {
        try await groupClient?.create(.init(name: name, organizationID: organization.id))
    }

    func patchName(_ id: String, name: String) async throws -> VOGroup.Entity? {
        try await groupClient?.patchName(id, options: .init(name: name))
    }

    func delete() async throws {
        guard let current else { return }
        try await groupClient?.delete(current.id)
    }

    func addMember(userID: String) async throws {
        guard let current else { return }
        try await groupClient?.addMember(current.id, options: .init(userID: userID))
    }

    // MARK: - Entities

    func append(_ newEntities: [VOGroup.Entity]) {
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
            if let current = self.current {
                Task {
                    let group = try await self.fetch(current.id)
                    if let group {
                        DispatchQueue.main.async {
                            self.current = group
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
