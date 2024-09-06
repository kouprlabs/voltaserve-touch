import Combine
import Foundation
import Voltaserve

class OrganizationMembersStore: ObservableObject {
    @Published var list: VOUser.List?
    @Published var entities: [VOUser.Entity]?
    private var timer: Timer?

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

    private var client: VOUser?

    func fetchList(
        _ organizationID: String,
        page: Int = 1,
        size: Int = Constants.pageSize
    ) async throws -> VOUser.List? {
        try await client?.fetchList(.init(organizationID: organizationID, page: page, size: size))
    }

    func append(_ newEntities: [VOUser.Entity]) {
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

    func startRefreshTimer(_ organizationID: String) {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if let entities = self.entities {
                Task {
                    let list = try await self.fetchList(organizationID, page: 1, size: entities.count)
                    if let list {
                        Task { @MainActor in
                            self.entities = list.data
                        }
                    }
                }
            }
        }
    }

    func stopRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }

    private enum Constants {
        static let pageSize = 10
    }
}
