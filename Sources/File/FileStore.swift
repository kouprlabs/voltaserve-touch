import Combine
import Foundation
import Voltaserve

class FileStore: ObservableObject {
    @Published var list: VOFile.List?

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

    private var client: VOFile?

    func fetchList(_ id: String) async throws -> VOFile.List? {
        try await client?.fetchList(id, options: .init(page: 1, size: 100))
    }
}
