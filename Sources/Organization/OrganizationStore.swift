import Combine
import Foundation
import Voltaserve

class OrganizationStore: ObservableObject {
    @Published var list: VOOrganization.List?
    @Published var members: VOUser.List?
    @Published var current: VOOrganization.Entity?
    @Published var invitations: VOInvitation.List?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                userClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOOrganization?
    private var userClient: VOUser?
    private var invitationClient: VOInvitation?

    init() {}

    init(_ current: VOOrganization.Entity) {
        self.current = current
    }

    func fetchList() async throws -> VOOrganization.List? {
        try await client?.fetchList(.init())
    }

    func fetchMembers(_ id: String) async throws -> VOUser.List? {
        try await userClient?.fetchList(.init(organizationID: id))
    }

    func fetchInvitations(_ id: String) async throws -> VOInvitation.List? {
        try await invitationClient?.fetchOutgoing(.init(organizationID: id))
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
