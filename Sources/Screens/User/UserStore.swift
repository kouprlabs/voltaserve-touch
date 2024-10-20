import Combine
import Foundation
import VoltaserveCore

class UserStore: ObservableObject {
    @Published var entities: [VOUser.Entity]?
    @Published var query: String?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var searchText = ""
    private var list: VOUser.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var userClient: VOUser?
    let searchPublisher = PassthroughSubject<String, Never>()
    var organizationID: String?
    var groupID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                userClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    init() {
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    private func fetchProbe(size: Int = Constants.pageSize) async throws -> VOUser.Probe? {
        if let organizationID {
            return try await userClient?.fetchProbe(.init(
                query: query,
                organizationID: organizationID,
                size: size
            ))
        } else if let groupID {
            return try await userClient?.fetchProbe(.init(
                query: query,
                groupID: groupID,
                size: size
            ))
        }
        return nil
    }

    private func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOUser.List? {
        if let organizationID {
            return try await userClient?.fetchList(.init(
                query: query,
                organizationID: organizationID,
                page: page,
                size: size
            ))
        } else if let groupID {
            return try await userClient?.fetchList(.init(
                query: query,
                groupID: groupID,
                page: page,
                size: size
            ))
        }
        return nil
    }

    func fetchNext(replace: Bool = false) {
        var nextPage = -1
        var list: VOUser.List?

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
            self.errorTitle = "Error: Fetching Users"
            self.errorMessage = message
            self.showError = true
        }
    }

    // MARK: - Entities

    func append(_ newEntities: [VOUser.Entity]) {
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
        static let pageSize = 10
    }
}
