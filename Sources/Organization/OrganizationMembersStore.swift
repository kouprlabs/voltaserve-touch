import Combine
import Foundation
import Voltaserve

class OrganizationMembersStore: ObservableObject {
    @Published var list: VOUser.List?

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

    func fetchList(_ id: String) async throws -> VOUser.List? {
        try await client?.fetchList(.init(organizationID: id))
    }
}
