import Combine
import Foundation
import Voltaserve

class OrganizationMembersStore: ObservableObject {
    @Published var list: VOUser.List?
    @Published var entities: [VOUser.Entity]?

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

    private var client: VOUser?

    func fetchList(_ id: String, page: Int = 1, size: Int = Constants.pageSize) async throws -> VOUser.List? {
        try await client?.fetchList(.init(organizationID: id, page: page, size: size))
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

    private enum Constants {
        static let pageSize = 10
    }
}
