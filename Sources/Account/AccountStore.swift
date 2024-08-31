import Foundation
import Voltaserve

class AccountStore: ObservableObject {
    @Published var user: VOAuthUser.Entity?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(baseURL: Config.production.idpURL)
                authUserClient = .init(
                    baseURL: Config.production.idpURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOAccount?
    private var authUserClient: VOAuthUser?

    func fetchUser() async throws -> VOAuthUser.Entity? {
        try await authUserClient?.fetch()
    }

    func update(email: String, fullName: String) async throws {
        try await withCheckedThrowingContinuation { continutation in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                if let user {
                    self.user = .init(
                        id: user.id,
                        username: user.username,
                        email: email,
                        fullName: fullName,
                        picture: user.picture
                    )
                }
                continutation.resume()
            }
        }
    }
}
