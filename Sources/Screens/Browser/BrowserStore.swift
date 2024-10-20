import Combine
import Foundation
import VoltaserveCore

class BrowserStore: ObservableObject {
    @Published var entities: [VOFile.Entity]?
    @Published var current: VOFile.Entity?
    @Published var query: VOFile.Query?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isLoading = false
    private var list: VOFile.List?
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var fileClient: VOFile?
    var fileID: String?
    let searchPublisher = PassthroughSubject<String, Never>()

    var token: VOToken.Value? {
        didSet {
            if let token {
                fileClient = .init(
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
                self.query = .init(text: $0)
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    private func fetch(_ id: String) async throws -> VOFile.Entity? {
        try await fileClient?.fetch(id)
    }

    func fetch() {
        guard let fileID else { return }
        var file: VOFile.Entity?

        withErrorHandling {
            file = try await self.fetch(fileID)
            return true
        } success: {
            self.current = file
        } failure: { message in
            self.errorTitle = "Error: Fetching File"
            self.errorMessage = message
            self.showError = true
        }
    }

    private func fetchProbe(_ id: String, size: Int = Constants.pageSize) async throws -> VOFile.Probe? {
        try await fileClient?.fetchProbe(id, options: .init(query: query, size: size, type: .folder))
    }

    private func fetchList(_ id: String, page: Int = 1, size: Int = Constants.pageSize) async throws -> VOFile.List? {
        try await fileClient?.fetchList(id, options: .init(query: query, page: page, size: size, type: .folder))
    }

    func fetchNext(replace: Bool = false) {
        guard let fileID else { return }
        guard !isLoading else { return }

        var nextPage = -1
        var list: VOFile.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.fetchProbe(fileID, size: Constants.pageSize)
                if let probe {
                    self.list = .init(
                        data: list.data,
                        totalPages: probe.totalPages,
                        totalElements: probe.totalElements,
                        page: list.page,
                        size: list.size,
                        query: list.query
                    )
                }
            }
            if !self.hasNextPage() { return false }
            nextPage = self.nextPage()
            list = try await self.fetchList(fileID, page: nextPage)
            return true
        } before: {
            self.isLoading = true
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
            self.errorTitle = "Error: Fetching Files"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    // MARK: - Entities

    func append(_ newEntities: [VOFile.Entity]) {
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

    // MARK: - Paging

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

    func isEntityThreshold(_ id: String) -> Bool {
        if let entities {
            let threashold = Constants.pageSize / 2
            if entities.count >= threashold,
               entities.firstIndex(where: { $0.id == id }) == entities.count - threashold {
                return true
            } else {
                return id == entities.last?.id
            }
        }
        return false
    }

    // MARK: - Timer

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let current = self.current {
                Task {
                    var size = Constants.pageSize
                    if let list = self.list {
                        size = Constants.pageSize * list.page
                    }
                    let list = try await self.fetchList(current.id, page: 1, size: size)
                    if let list {
                        DispatchQueue.main.async {
                            self.entities = list.data
                        }
                    }
                }
            }
            if let current = self.current {
                Task {
                    let file = try await self.fetch(current.id)
                    if let file {
                        DispatchQueue.main.async {
                            self.current = file
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

    // MARK: - Constants

    private enum Constants {
        static let pageSize = 50
    }
}
