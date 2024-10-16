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
    private var invitationClient: VOInvitation?
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

    func create(organizationID: String, emails: [String]) async throws -> [VOInvitation.Entity]? {
        try await invitationClient?.create(.init(organizationID: organizationID, emails: emails))
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

    func fetchIncomingCount() {
        var count: Int?
        withErrorHandling {
            count = try await self.fetchIncomingCount()
            return true
        } success: {
            self.incomingCount = count
        } failure: { message in
            self.errorTitle = "Error: Fetching Invitation Incoming Count"
            self.errorMessage = message
            self.showError = true
        }
    }

    func accept(_ id: String) async throws {
        try await invitationClient?.accept(id)
    }

    func decline(_ id: String) async throws {
        try await invitationClient?.decline(id)
    }

    func append(_ newEntities: [VOInvitation.Entity]) {
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
            if let entities = self.entities {
                Task {
                    let list = try await self.fetchList(page: 1, size: entities.count)
                    if let list {
                        DispatchQueue.main.async {
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
