import Combine
import Foundation
import VoltaserveCore

class WorkspaceStore: ObservableObject {
    @Published var list: VOWorkspace.List?
    @Published var entities: [VOWorkspace.Entity]?
    @Published var current: VOWorkspace.Entity?
    @Published var root: VOFile.Entity?
    @Published var storageUsage: VOStorage.Usage?
    @Published var query: String?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var selection: String?
    @Published var searchText = ""
    @Published var isLoading = false
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var workspaceClient: VOWorkspace?
    private var fileClient: VOFile?
    private var storageClient: VOStorage?
    let searchPublisher = PassthroughSubject<String, Never>()

    var token: VOToken.Value? {
        didSet {
            if let token {
                workspaceClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                fileClient = .init(
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

    init() {
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    func create(
        name: String,
        organization: VOOrganization.Entity,
        storageCapacity: Int
    ) async throws -> VOWorkspace.Entity? {
        try await workspaceClient?.create(.init(
            name: name,
            organizationID: organization.id,
            storageCapacity: storageCapacity
        ))
    }

    func fetch(_ id: String) async throws -> VOWorkspace.Entity? {
        try await workspaceClient?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOWorkspace.List? {
        try await workspaceClient?.fetchList(.init(query: query, page: page, size: size))
    }

    func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOWorkspace.List?

        withErrorHandling {
            if !self.hasNextPage() { return false }
            nextPage = self.nextPage()
            list = try await self.fetchList(page: nextPage)
            return true
        } success: {
            self.list = list
            if let list {
                if replace, nextPage == 1 {
                    self.entities = list.data
                } else {
                    self.append(list.data)
                }
            }
        } failure: { message in
            self.errorTitle = "Error: Fetching Workspaces"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func fetchFile(_ id: String) async throws -> VOFile.Entity? {
        try await fileClient?.fetch(id)
    }

    func fetchRoot() {
        guard let current else { return }

        var root: VOFile.Entity?

        withErrorHandling {
            root = try await self.fetchFile(current.rootID)
            return true
        } success: {
            self.root = root
        } failure: { message in
            self.errorTitle = "Error: Fetching Workspace Root"
            self.errorMessage = message
            self.showError = true
        }
    }

    func fetchStorageUsage(_ id: String) async throws -> VOStorage.Usage? {
        try await storageClient?.fetchWorkspaceUsage(id)
    }

    func patchName(name: String) async throws -> VOWorkspace.Entity? {
        guard let current else { return nil }
        return try await workspaceClient?.patchName(current.id, options: .init(name: name))
    }

    func patchStorageCapacity(storageCapacity: Int) async throws -> VOWorkspace.Entity? {
        guard let current else { return nil }
        return try await workspaceClient?.patchStorageCapacity(
            current.id,
            options: .init(storageCapacity: storageCapacity)
        )
    }

    func delete() async throws {
        guard let current else { return }
        try await workspaceClient?.delete(current.id)
    }

    func append(_ newEntities: [VOWorkspace.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.id == newEntity.id }) {
            entities!.append(newEntity)
        }
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
            Task {
                var size = Constants.pageSize
                if let list = self.list {
                    size = Constants.pageSize * list.page
                }
                let list = try await self.fetchList(page: 1, size: size)
                if let list {
                    DispatchQueue.main.async {
                        self.entities = list.data
                    }
                }
            }
            if let current = self.current {
                Task {
                    let workspace = try await self.fetch(current.id)
                    if let workspace {
                        DispatchQueue.main.async {
                            self.current = workspace
                        }
                    }
                }
                Task {
                    let root = try await self.fetchFile(current.rootID)
                    if let root {
                        DispatchQueue.main.async {
                            self.root = root
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
