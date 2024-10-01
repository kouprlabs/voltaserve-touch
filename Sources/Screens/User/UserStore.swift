import Combine
import Foundation
import VoltaserveCore

class UserStore: ObservableObject {
    @Published var list: VOUser.List?
    @Published var entities: [VOUser.Entity]?
    @Published var query: String?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isLoading = false
    let searchPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
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

    private var userClient: VOUser?

    init() {
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOUser.List? {
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

    func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOUser.List?

        withErrorHandling {
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
        } anyways: {
            self.isLoading = false
        }
    }

    func append(_ newEntities: [VOUser.Entity]) {
        if entities == nil {
            entities = []
        }
        entities!.append(contentsOf: newEntities)
    }

    func clear() {
        entities = nil
        list = nil
    }

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

    func isLast(_ id: String) -> Bool {
        id == entities?.last?.id
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                var size = Constants.pageSize
                if let entities = self.entities, !entities.isEmpty {
                    size = entities.count
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

    private enum Constants {
        static let pageSize = 10
    }
}
