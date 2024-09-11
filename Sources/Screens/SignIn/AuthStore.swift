import Combine
import Foundation
import VoltaserveCore

class AuthStore: ObservableObject {
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
}

extension VOToken.Value {
    static let devInstance = VOToken.Value(
        // swiftlint:disable:next line_length
        accessToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjQ5NzMyNDcsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNzU2NTI0N30.KTNVpdVdzMB3TeK9W8dEE9nhzxT67VJ3FDXU_bxr-Wo",
        expiresIn: 1_727_565_247,
        tokenType: "Bearer",
        refreshToken: "2c9188e51642424e8caaf4704f1beadf"
    )

    var isExpired: Bool {
        Int(Date().timeIntervalSince1970) >= expiresIn
    }
}
