import Combine
import Foundation
import VoltaserveCore

class GroupStore: ObservableObject {
    @Published var list: VOGroup.List?
    @Published var entities: [VOGroup.Entity]?
    @Published var current: VOGroup.Entity?
    @Published var query: String?
    private var timer: Timer?

    var token: VOToken.Value? {
        didSet {
            if let token {
                groupClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var groupClient: VOGroup?

    init() {}

    init(_ current: VOGroup.Entity) {
        self.current = current
    }

    func fetch(_ id: String) async throws -> VOGroup.Entity? {
        try await groupClient?.fetch(id)
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOGroup.List? {
        try await groupClient?.fetchList(.init(query: query, page: page, size: size))
    }

    func patchName(_: String, options _: VOGroup.PatchNameOptions) async throws {
        try await Fake.serverCall { continuation in
            if let current = self.current,
               current.name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func delete(_: String) async throws {
        try await Fake.serverCall { continuation in
            if let current = self.current,
               current.name.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func append(_ newEntities: [VOGroup.Entity]) {
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
                    let group = try await self.fetch(current.id)
                    if let group {
                        Task { @MainActor in
                            self.current = group
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
