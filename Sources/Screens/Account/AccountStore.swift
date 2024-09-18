import Foundation
import VoltaserveCore

class AccountStore: ObservableObject {
    @Published var identityUser: VOIdentityUser.Entity?
    @Published var storageUsage: VOStorage.Usage?
    private var timer: Timer?

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

    private var accountClient: VOAccount?
    private var identityUserClient: VOIdentityUser?
    private var storageClient: VOStorage?

    init(_ identityUser: VOIdentityUser.Entity? = nil) {
        self.identityUser = identityUser
    }

    func fetchUser() async throws -> VOIdentityUser.Entity? {
        try await identityUserClient?.fetch()
    }

    func fetchAccountStorageUsage() async throws -> VOStorage.Usage? {
        try await storageClient?.fetchAccountUsage()
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
                        Task { @MainActor in
                            self.identityUser = user
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

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
