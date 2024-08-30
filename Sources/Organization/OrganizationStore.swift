import Combine
import Foundation
import Voltaserve

class OrganizationStore: ObservableObject {
    @Published var list: VOOrganization.List?

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

    func fetchList() async throws -> VOOrganization.List? {
        try await client?.fetchList(.init())
    }
}
