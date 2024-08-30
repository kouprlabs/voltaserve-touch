import Combine
import Foundation
import Voltaserve

class GroupStore: ObservableObject {
    @Published var list: VOGroup.List?

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

    func fetchList() async throws -> VOGroup.List? {
        try await client?.fetchList(.init())
    }
}
