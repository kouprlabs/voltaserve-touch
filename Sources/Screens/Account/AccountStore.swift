import Foundation
import VoltaserveCore

class AccountStore: ObservableObject {
    @Published var identityUser: VOIdentityUser.Entity?
    @Published var storageUsage: VOStorage.Usage?
    @Published var showError = false
    @Published var errorTitle: String?
    @Published var errorMessage: String?
    private var timer: Timer?
    private var accountClient: VOAccount?
    private var identityUserClient: VOIdentityUser?
    private var storageClient: VOStorage?
    var tokenStore: TokenStore?

    var token: VOToken.Value? {
        didSet {
            if let token {
                accountClient = .init(baseURL: Config.production.idpURL)
                identityUserClient = .init(
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

    init(_ identityUser: VOIdentityUser.Entity? = nil) {
        self.identityUser = identityUser
    }

    func fetchUser() async throws -> VOIdentityUser.Entity? {
        try await identityUserClient?.fetch()
    }

    func fetchUser() {
        var user: VOIdentityUser.Entity?
        withErrorHandling {
            user = try await self.fetchUser()
            return true
        } success: {
            self.identityUser = user
        } failure: { message in
            self.errorTitle = "Error: Fetching User"
            self.errorMessage = message
            self.showError = true
        } invalidCreditentials: {
            self.tokenStore?.token = nil
            self.tokenStore?.deleteFromKeychain()
        }
    }

    func fetchAccountStorageUsage() async throws -> VOStorage.Usage? {
        try await storageClient?.fetchAccountUsage()
    }

    func fetchAccountStorageUsage() {
        var usage: VOStorage.Usage?
        withErrorHandling {
            usage = try await self.fetchAccountStorageUsage()
            return true
        } success: {
            self.storageUsage = usage
        } failure: { message in
            self.errorTitle = "Error: Fetching Storage Usage"
            self.errorMessage = message
            self.showError = true
        }
    }

    func updateEmail(_: String) async throws {
        try await Fake.serverCall { continuation in
            if let identityUser = self.identityUser,
               identityUser.fullName.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func updateFullName(_: String) async throws {
        try await Fake.serverCall { continuation in
            if let identityUser = self.identityUser,
               identityUser.fullName.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func updatePassword(current _: String, new _: String) async throws {
        try await Fake.serverCall { continuation in
            if let identityUser = self.identityUser,
               identityUser.fullName.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func deleteAccount() async throws {
        try await Fake.serverCall { continuation in
            if let identityUser = self.identityUser,
               identityUser.fullName.lowercasedAndTrimmed().starts(with: "error") {
                continuation.resume(throwing: Fake.serverError)
            } else {
                continuation.resume()
            }
        }
    }

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.identityUser != nil {
                Task {
                    let user = try await self.fetchUser()
                    if let user {
                        DispatchQueue.main.async {
                            self.identityUser = user
                        }
                    }
                }
            }
            if self.storageUsage != nil {
                Task {
                    let storageUsage = try await self.fetchAccountStorageUsage()
                    if let storageUsage {
                        DispatchQueue.main.async {
                            self.storageUsage = storageUsage
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
}
