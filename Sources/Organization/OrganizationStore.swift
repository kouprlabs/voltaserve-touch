import Combine
import Foundation
import VoltaserveCore

class OrganizationStore: ObservableObject {
    @Published var list: VOOrganization.List?
    @Published var entities: [VOOrganization.Entity]?
    @Published var current: VOOrganization.Entity?
    @Published var query: String?
    private var timer: Timer?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOOrganization?

    init() {}

    init(_ current: VOOrganization.Entity) {
        self.current = current
    }

    func fetch(_ id: String) async throws -> VOOrganization.Entity? {
        try await client?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOOrganization.List? {
        try await client?.fetchList(.init(query: query, page: page, size: size))
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

extension VOOrganization.Entity {
    static let devInstance = VOOrganization.Entity(
        id: "aKQxy35RBP3p3",
        name: "My Organization",
        permission: .owner,
        createTime: Date().ISO8601Format()
    )
}
