import Combine
import Foundation
import VoltaserveCore

class WorkspaceStore: ObservableObject {
    @Published var list: VOWorkspace.List?
    @Published var entities: [VOWorkspace.Entity]?
    @Published var current: VOWorkspace.Entity?
    @Published var storageUsage: VOStorage.Usage?
    @Published var query: String?
    private var timer: Timer?

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

    init(_ current: VOWorkspace.Entity) {
        self.current = current
    }

    func fetch(_ id: String) async throws -> VOWorkspace.Entity? {
        try await client?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOWorkspace.List? {
        try await client?.fetchList(.init(query: query, page: page, size: size))
    }

    func fetchStorageUsage(_ id: String) async throws -> VOStorage.Usage? {
        try await storageClient?.fetchWorkspaceUsage(id)
    }

    func append(_ newEntities: [VOWorkspace.Entity]) {
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

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let entities = self.entities, !entities.isEmpty {
                Task {
                    let list = try await self.fetchList(page: 1, size: entities.count)
                    if let list {
                        Task { @MainActor in
                            self.entities = list.data
                        }
                    }
                }
            }
            if let current = self.current {
                Task {
                    let workspace = try await self.fetch(current.id)
                    if let workspace {
                        Task { @MainActor in
                            self.current = workspace
                        }
                    }
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private enum Constants {
        static let pageSize = 10
    }
}

extension VOWorkspace.Entity {
    static let devInstance = VOWorkspace.Entity(
        id: UUID().uuidString,
        name: "My Workspace",
        permission: .owner,
        storageCapacity: 5_000_000_000,
        rootID: UUID().uuidString,
        organization: VOOrganization.Entity.devInstance,
        createTime: Date().ISO8601Format()
    )
}
