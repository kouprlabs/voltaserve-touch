import Combine
import Foundation
import Voltaserve

class GroupStore: ObservableObject {
    @Published var list: VOGroup.List?
    @Published var members: VOUser.List?
    @Published var current: VOGroup.Entity?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
                userClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOGroup?
    private var userClient: VOUser?

    init() {}

    init(_ current: VOGroup.Entity) {
        self.current = current
    }

    func fetchList() async throws -> VOGroup.List? {
        try await client?.fetchList(.init())
    }

    func fetchMembers(_ id: String) async throws -> VOUser.List? {
        try await userClient?.fetchList(.init(groupID: id))
    }
}

extension VOGroup.Entity {
    static let devInstance = VOGroup.Entity(
        id: "QvlPbDzXrlJM1",
        name: "My Group",
        organization: VOOrganization.Entity.devInstance,
        permission: .owner,
        createTime: Date().ISO8601Format()
    )
}
