import Combine
import Foundation
import Voltaserve

class OrganizationStore: ObservableObject {
    @Published var list: VOOrganization.List?
    @Published var entities: [VOOrganization.Entity]?
    @Published var current: VOOrganization.Entity?
    @Published var invitations: VOInvitation.List?

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
    private var invitationClient: VOInvitation?

    init() {}

    init(_ current: VOOrganization.Entity) {
        self.current = current
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOOrganization.List? {
        try await client?.fetchList(.init(page: page, size: size))
    }

    func fetchInvitations(_ id: String) async throws -> VOInvitation.List? {
        try await invitationClient?.fetchOutgoing(.init(organizationID: id))
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
