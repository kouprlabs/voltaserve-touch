import Combine
import Foundation
import VoltaserveCore

class InvitationStore: ObservableObject {
    @Published var entities: [VOInvitation.Entity]?
    @Published var incomingCount: Int?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    private var list: VOInvitation.List?
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

    // MARK: - Fetch

    private func fetchProbe(size: Int = Constants.pageSize) async throws -> VOInvitation.Probe? {
        if let organizationID {
            try await invitationClient?.fetchOutgoingProbe(.init(organizationID: organizationID, size: size))
        } else {
            try await invitationClient?.fetchIncomingProbe(.init(size: size))
        }
    }

    private func fetchList(page: Int = 1, size: Int = Constants.pageSize) async throws -> VOInvitation.List? {
        if let organizationID {
            try await invitationClient?.fetchOutgoingList(.init(organizationID: organizationID, page: page, size: size))
        } else {
            try await invitationClient?.fetchIncomingList(.init(page: page, size: size))
        }
    }

    func fetchNext(replace: Bool = false) {
        var nextPage = -1
        var list: VOInvitation.List?

        withErrorHandling {
            if let list = self.list {
                let probe = try await self.fetchProbe(size: Constants.pageSize)
                if let probe {
                    self.list = .init(
                        data: list.data,
                        totalPages: probe.totalPages,
                        totalElements: probe.totalElements,
                        page: list.page,
                        size: list.size
                    )
                }
            }
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
        }
    }

    private func fetchIncomingCount() async throws -> Int? {
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

    // MARK: - Update

    func create(emails: [String]) async throws -> [VOInvitation.Entity]? {
        guard let organizationID else { return nil }
        return try await invitationClient?.create(.init(organizationID: organizationID, emails: emails))
    }

    func accept(_ id: String) async throws {
        try await invitationClient?.accept(id)
    }

    func decline(_ id: String) async throws {
        try await invitationClient?.decline(id)
    }

    func delete(_ id: String) async throws {
        try await invitationClient?.delete(id)
    }

    // MARK: - Entities

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
            Task {
                let incomingCount = try await self.fetchIncomingCount()
                if let incomingCount {
                    DispatchQueue.main.async {
                        self.incomingCount = incomingCount
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
        static let pageSize = 10
    }
}
