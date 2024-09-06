import Foundation
import Voltaserve

class AccountStore: ObservableObject {
    @Published var user: VOAuthUser.Entity?
    @Published var storageUsage: VOStorage.Usage?
    private var timer: Timer?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(baseURL: Config.production.idpURL)
                authUserClient = .init(
                    baseURL: Config.production.idpURL,
                    accessToken: token.accessToken
                )
                storageClient = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    private var client: VOAccount?
    private var authUserClient: VOAuthUser?
    private var storageClient: VOStorage?

    func fetchUser() async throws -> VOAuthUser.Entity? {
        try await authUserClient?.fetch()
    }

    func fetchAccountStorageUsage() async throws -> VOStorage.Usage? {
        try await storageClient?.fetchAccountUsage()
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

    func startRefreshTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.user != nil {
                Task {
                    let user = try await self.fetchUser()
                    if let user {
                        Task { @MainActor in
                            self.user = user
                        }
                    }
                }
            }
            if self.storageUsage != nil {
                Task {
                    let storageUsage = try await self.fetchAccountStorageUsage()
                    if let storageUsage {
                        Task { @MainActor in
                            self.storageUsage = storageUsage
                        }
                    }
                }
            }
        }
    }

    func stopRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }
}
