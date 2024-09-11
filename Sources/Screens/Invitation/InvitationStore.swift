import Combine
import Foundation
import VoltaserveCore

class InvitationStore: ObservableObject {
    @Published var list: VOInvitation.List?
    @Published var entities: [VOInvitation.Entity]?
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

    private var client: VOInvitation?

    func fetchList(_ id: String, page _: Int = 1, size _: Int = Constants.pageSize) async throws -> VOInvitation.List? {
        try await client?.fetchOutgoing(.init(organizationID: id))
    }

    func startRefreshToken(_ organizationID: String) {
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

    private enum Constants {
        static let pageSize = 10
    }
}
