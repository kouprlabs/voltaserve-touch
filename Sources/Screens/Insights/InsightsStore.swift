import Combine
import Foundation
import VoltaserveCore

class InsightsStore: ObservableObject {
    @Published var list: VOInsights.EntityList?
    @Published var entities: [VOInsights.Entity]?
    @Published var languages: [VOInsights.Language]?
    @Published var info: VOInsights.Info?
    @Published var query: String?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var isLoading = false
    private var cancellables: Set<AnyCancellable> = []
    private var timer: Timer?
    private var insightsClient: VOInsights?
    let searchPublisher = PassthroughSubject<String, Never>()
    var fileID: String?
    var pageSize: Int?

    var token: VOToken.Value? {
        didSet {
            if let token {
                insightsClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    init(fileID: String? = nil, pageSize: Int? = nil) {
        self.fileID = fileID
        self.pageSize = pageSize
        searchPublisher
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink {
                self.query = $0
            }
            .store(in: &cancellables)
    }

    func create(languageID: String) async throws -> VOTask.Entity? {
        guard let fileID else { return nil }
        return try await insightsClient?.create(fileID, options: .init(languageID: languageID))
    }

    func patch() async throws -> VOTask.Entity? {
        guard let fileID else { return nil }
        return try await insightsClient?.patch(fileID)
    }

    func delete() async throws -> VOTask.Entity? {
        guard let fileID else { return nil }
        return try await insightsClient?.delete(fileID)
    }

    func fetchLanguages() async throws -> [VOInsights.Language]? {
        try await insightsClient?.fetchLanguages()
    }

    func fetchLanguages() {
        var languages: [VOInsights.Language]?
        withErrorHandling {
            languages = try await self.fetchLanguages()
            return true
        } success: {
            self.languages = languages
        } failure: { message in
            self.errorTitle = "Error: Fetching Insights Languages"
            self.errorMessage = message
            self.showError = true
        }
    }

    func fetchInfo() async throws -> VOInsights.Info? {
        guard let fileID else { return nil }
        return try await insightsClient?.fetchInfo(fileID)
    }

    func fetchInfo() {
        var info: VOInsights.Info?
        withErrorHandling {
            info = try await self.fetchInfo()
            return true
        } success: {
            self.info = info
        } failure: { message in
            self.errorTitle = "Error: Fetching Insights Info"
            self.errorMessage = message
            self.showError = true
        }
    }

    func fetchEntityList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOInsights.EntityList? {
        guard let fileID else { return nil }
        return try await insightsClient?.fetchEntityList(
            fileID,
            options: .init(query: query, page: page, size: pageSize ?? size, sortBy: .frequency, sortOrder: .desc)
        )
    }

    func fetchEntityList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOInsights.EntityList?

        withErrorHandling {
            if !self.hasNextPage() { return false }
            nextPage = self.nextPage()
            list = try await self.fetchEntityList(page: nextPage)
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
            self.errorTitle = "Error: Fetching Insights Entities"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func append(_ newEntities: [VOInsights.Entity]) {
        if entities == nil {
            entities = []
        }
        for newEntity in newEntities where !entities!.contains(where: { $0.text == newEntity.text }) {
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
        id == entities?.last?.text
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task {
                var size = Constants.pageSize
                if let list = self.list {
                    size = Constants.pageSize * list.page
                }
                let list = try await self.fetchEntityList(page: 1, size: size)
                if let list {
                    DispatchQueue.main.async {
                        self.entities = list.data
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
