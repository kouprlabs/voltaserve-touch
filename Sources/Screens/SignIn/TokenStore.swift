import Combine
import Foundation
import VoltaserveCore

class TokenStore: ObservableObject {
    @Published var token: VOToken.Value?
    private var client = VOToken(baseURL: Config.production.idpURL)

    init() {}

    init(_ token: VOToken.Value) {
        self.token = token
    }

    func signIn(username: String, password: String) async throws -> VOToken.Value {
        try await client.exchange(.init(
            grantType: .password,
            username: username,
            password: password
        ))
    }

    func refreshTokenIfNecessary() async throws -> VOToken.Value? {
        guard token != nil else { return nil }
        if let token, token.isExpired {
            if let newToken = try? await client.exchange(.init(
                grantType: .refreshToken,
                refreshToken: token.refreshToken
            )) {
                return newToken
            }
        }
        return nil
    }

    func loadFromKeyChain() -> VOToken.Value? {
        KeychainManager.standard.getToken(KeychainManager.Constants.tokenKey)
    }

    func saveInKeychain(_ token: VOToken.Value) {
        KeychainManager.standard.saveToken(token, forKey: KeychainManager.Constants.tokenKey)
    }

    func deleteFromKeychain() {
        KeychainManager.standard.delete(KeychainManager.Constants.tokenKey)
    }
}

extension VOToken.Value {
    var isExpired: Bool {
        Int(Date().timeIntervalSince1970) >= expiresIn
    }
}
