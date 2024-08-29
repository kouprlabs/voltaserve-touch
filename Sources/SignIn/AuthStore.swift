import Combine
import Voltaserve

class AuthStore: ObservableObject {
    @Published var token: VOToken.Value?
    private var client = VOToken(baseURL: GlobalConstants.config.idpURL)

    func signIn(username: String, password: String) async throws -> VOToken.Value {
        try await client.exchange(.init(
            grantType: .password,
            username: username,
            password: password
        ))
    }
}
