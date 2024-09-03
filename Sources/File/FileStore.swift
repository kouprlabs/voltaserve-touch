import Combine
import Foundation
import Voltaserve

class FileStore: ObservableObject {
    @Published var list: VOFile.List?
    @Published var entities: [VOFile.Entity]?
    @Published var current: VOFile.Entity?

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

    func fetch(_ id: String) async throws -> VOFile.Entity? {
        try await client?.fetch(id)
    }

    func fetchList(_ id: String, page: Int = 1) async throws -> VOFile.List? {
        try await client?.fetchList(id, options: .init(page: page, size: 20))
    }

    func clear() {
        entities = nil
        list = nil
    }

    func isLast(_ id: String) -> Bool {
        id == entities?.last?.id
    }

    func append(_ newEntities: [VOFile.Entity]) {
        if entities == nil {
            entities = []
        }
        entities!.append(contentsOf: newEntities)
    }

    func nextPage() -> Int {
        var page = 1
        if let existingList = list {
            if existingList.page < existingList.totalPages {
                page = existingList.page + 1
            } else if existingList.page == existingList.totalPages {
                return -1
            }
        }
        return page
    }

    func hasNextPage() -> Bool {
        nextPage() != -1
    }
}
