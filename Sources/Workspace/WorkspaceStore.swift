import Combine
import Foundation
import Voltaserve

class WorkspaceStore: ObservableObject {
    @Published var list: VOWorkspace.List?
    @Published var current: VOWorkspace.Entity?

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

    private var client: VOWorkspace?

    init() {
        #if targetEnvironment(simulator)
            current = .init(
                id: UUID().uuidString,
                name: "My Workspace",
                permission: .owner,
                storageCapacity: 100_000_000_000,
                rootID: UUID().uuidString,
                organization: .init(
                    id: UUID().uuidString,
                    name: "My Organization",
                    permission: .owner,
                    createTime: Date().ISO8601Format()
                ),
                createTime: Date().ISO8601Format()
            )
        #endif
    }

    func fetchList() async throws -> VOWorkspace.List? {
        try await client?.fetchList(.init())
    }
}
