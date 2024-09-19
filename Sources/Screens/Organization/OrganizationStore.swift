import Combine
import Foundation
import VoltaserveCore

class OrganizationStore: ObservableObject {
    @Published var list: VOOrganization.List?
    @Published var entities: [VOOrganization.Entity]?
    @Published var current: VOOrganization.Entity?
    @Published var query: String?
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    let searchPublisher = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    var token: VOToken.Value? {
        didSet {
            if let token {
                organizationClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var organizationClient: VOOrganization?

    init() {
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    func fetch(_ id: String) async throws -> VOOrganization.Entity? {
        try await organizationClient?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOOrganization.List? {
        try await organizationClient?.fetchList(.init(query: query, page: page, size: size))
    }

    func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOOrganization.List?

        VOErrorResponse.withErrorHandling {
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
            self.errorTitle = "Error: Fetching Organizations"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func patchName(_: String, name _: String) async throws {
        try await Fake.serverCall { continuation in
            if let current = self.current,
               current.name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func delete(_: String) async throws {
        try await Fake.serverCall { continuation in
            if let current = self.current,
               current.name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func append(_ newEntities: [VOOrganization.Entity]) {
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
            if let entities = self.entities, !entities.isEmpty {
                Task {
                    let list = try await self.fetchList(page: 1, size: entities.count)
                    if let list {
                        Task { @MainActor in
                            self.entities = list.data
                        }
                    }
                }
            }
            if let current = self.current {
                Task {
                    let organization = try await self.fetch(current.id)
                    if let organization {
                        Task { @MainActor in
                            self.current = organization
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

    private enum Constants {
        static let pageSize = 10
    }
}
