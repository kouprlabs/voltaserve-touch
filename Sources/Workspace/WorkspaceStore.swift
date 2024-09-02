import Combine
import Foundation
import Voltaserve

class WorkspaceStore: ObservableObject {
    @Published var list: VOWorkspace.List?
    @Published var current: VOWorkspace.Entity?
    @Published var storageUsage: VOStorage.Usage?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                storageClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOWorkspace?
    private var storageClient: VOStorage?

    init() {}

    init(current: VOWorkspace.Entity) {
        self.current = current
    }

    func fetchStorageUsage(_ id: String) async throws -> VOStorage.Usage? {
        try await storageClient?.fetchWorkspaceUsage(id)
    }

    func fetchList() async throws -> VOWorkspace.List? {
        try await client?.fetchList(.init())
    }
}

extension VOWorkspace.Entity {
    static let devInstance = VOWorkspace.Entity(
        id: "xexj71g2865Ra",
        name: "My Workspace",
        permission: .owner,
        storageCapacity: 5_000_000_000,
        rootID: "x1novkR9M4YOe",
        organization: VOOrganization.Entity.devInstance,
        createTime: Date().ISO8601Format()
    )
}
