import Combine
import Foundation
import VoltaserveCore

class InvitationStore: ObservableObject {
    @Published var list: VOInvitation.List?
    @Published var entities: [VOInvitation.Entity]?
    @Published var incomingCount: Int?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    @Published var isLoading = false
    private var timer: Timer?
    var organizationID: String?

    var token: VOToken.Value? {
        didSet {
            if let token {
                invitationClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var invitationClient: VOInvitation?

    func create(organizationID _: String, emails: [String]) async throws {
        try await Fake.serverCall { continuation in
            if !emails.isEmpty, emails[0].lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOInvitation.List? {
        if let organizationID {
            try await invitationClient?.fetchOutgoing(.init(organizationID: organizationID, page: page, size: size))
        } else {
            try await invitationClient?.fetchIncoming(.init(page: page, size: size))
        }
    }

    func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOInvitation.List?

        withErrorHandling {
            if !self.hasNextPage() { return true }
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
            self.errorTitle = "Error: Fetching Invitations"
            self.errorMessage = message
            self.showError = true
        } anyways: {
            self.isLoading = false
        }
    }

    func fetchIncomingCount() async throws -> Int? {
        try await invitationClient?.fetchIncomingCount()
    }

    func accept(_: String) async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func decline(_: String) async throws {
        try await Fake.serverCall { continuation in
            continuation.resume()
        }
    }

    func append(_ newEntities: [VOInvitation.Entity]) {
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
            if let entities = self.entities {
                Task {
                    let list = try await self.fetchList(page: 1, size: entities.count)
                    if let list {
                        Task { @MainActor in
                            self.entities = list.data
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
