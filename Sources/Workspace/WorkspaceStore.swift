import Combine
import Foundation
import Voltaserve

class WorkspaceStore: ObservableObject {
    @Published var list: VOWorkspace.List?
    var token: VOToken.Value? {
        didSet {
            if let token {
                client = VOWorkspace(
                    baseURL: GlobalConstants.config.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOWorkspace?

    func fetchList() async throws -> VOWorkspace.List? {
        try await client?.fetchList(.init())
    }
}
