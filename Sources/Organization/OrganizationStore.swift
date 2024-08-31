import Combine
import Foundation
import Voltaserve

class OrganizationStore: ObservableObject {
    @Published var list: VOOrganization.List?
    @Published var members: VOUser.List?

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

    func fetchList() async throws -> VOOrganization.List? {
        try await client?.fetchList(.init())
    }

    func fetchMembers(_ id: String) async throws -> VOUser.List? {
        try await userClient?.fetchList(.init(organizationID: id))
    }
}
