import Combine
import Foundation
import VoltaserveCore

class GroupStore: ObservableObject {
    @Published var list: VOGroup.List?
    @Published var entities: [VOGroup.Entity]?
    @Published var current: VOGroup.Entity?
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

    private var groupClient: VOGroup?

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

    func create(name: String, organization: VOOrganization.Entity) async throws -> VOGroup.Entity? {
        try await Fake.serverCall { (continuation: CheckedContinuation<VOGroup.Entity?, any Error>) in
            if name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume(returning: VOGroup.Entity(
                    id: UUID().uuidString,
                    name: name,
                    organization: organization,
                    permission: .owner,
                    createTime: Date().ISO8601Format()
                ))
            }
        }
    }

    func fetch(_ id: String) async throws -> VOGroup.Entity? {
        try await groupClient?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOGroup.List? {
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

    func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOGroup.List?

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
            self.errorTitle = "Error: Fetching Groups"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func patchName(_: String, options _: VOGroup.PatchNameOptions) async throws {
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

    func addMember(_: String) async throws {
        try await Fake.serverCall { continuation in
            if let current = self.current,
               current.name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

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

    private enum Constants {
        static let pageSize = 10
    }
}
