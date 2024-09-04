import Combine
import Foundation
import Voltaserve

class GroupStore: ObservableObject {
    @Published var list: VOGroup.List?
    @Published var entities: [VOGroup.Entity]?
    @Published var current: VOGroup.Entity?

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

    private var client: VOGroup?

    init() {}

    init(_ current: VOGroup.Entity) {
        self.current = current
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOGroup.List? {
        try await client?.fetchList(.init(page: page, size: size))
    }

    func append(_ newEntities: [VOGroup.Entity]) {
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

    private enum Constants {
        static let pageSize = 10
    }
}

extension VOGroup.Entity {
    static let devInstance = VOGroup.Entity(
        id: "QvlPbDzXrlJM1",
        name: "My Group",
        organization: VOOrganization.Entity.devInstance,
        permission: .owner,
        createTime: Date().ISO8601Format()
    )
}
