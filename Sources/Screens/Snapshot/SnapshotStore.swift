import Combine
import Foundation
import VoltaserveCore

class SnapshotStore: ObservableObject {
    @Published var list: VOSnapshot.List?
    @Published var entities: [VOSnapshot.Entity]?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    private var timer: Timer?
    private var snapshotClient: VOSnapshot?
    var fileID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                snapshotClient = VOSnapshot(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    func fetch(id: String) async throws -> VOSnapshot.Entity? {
        try await snapshotClient?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOSnapshot.List? {
        guard let fileID else { return nil }
        return try await snapshotClient?.fetchList(.init(fileID: fileID, page: page, size: size, sortOrder: .desc))
    }

    func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOSnapshot.List?

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
            self.errorTitle = "Error: Fetching Snapshots"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func activate(_ id: String) async throws {
        try await snapshotClient?.activate(id)
    }

    func detach(_ id: String) async throws {
        try await snapshotClient?.detach(id)
    }

    func append(_ newEntities: [VOSnapshot.Entity]) {
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
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private enum Constants {
        static let pageSize: Int = 10
    }
}
