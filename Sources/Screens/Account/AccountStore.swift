// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Foundation
import VoltaserveCore

class AccountStore: ObservableObject {
    @Published var identityUser: VOIdentityUser.Entity?
    @Published var identityUserError: String?
    @Published var identityUserIsLoading: Bool = false
    @Published var storageUsage: VOStorage.Usage?
    @Published var storageUsageError: String?
    @Published var storageUsageIsLoading: Bool = false
    private var timer: Timer?
    private var accountClient: VOAccount = .init(baseURL: Config.production.idpURL)
    private var identityUserClient: VOIdentityUser?
    private var storageClient: VOStorage?
    var tokenStore: TokenStore?

    var token: VOToken.Value? {
        didSet {
            if let token {
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

    // MARK: - URLs

    func urlForUserPicture(_ id: String, fileExtension: String? = nil) -> URL? {
        if let fileExtension {
            return identityUserClient?.urlForPicture(id, fileExtension: fileExtension)
        }
        return nil
    }

    private func fetchIdentityUser() async throws -> VOIdentityUser.Entity? {
        try await identityUserClient?.fetch()
    }

    // MARK: - Fetch

    func fetchIdentityUser() {
        var identityUser: VOIdentityUser.Entity?
        withErrorHandling {
            identityUser = try await self.fetchIdentityUser()
            return true
        } before: {
            self.identityUserIsLoading = true
        } success: {
            self.identityUser = identityUser
        } failure: { message in
            self.identityUserError = message
        } invalidCredentials: {
            self.tokenStore?.token = nil
            self.tokenStore?.deleteFromKeychain()
        } anyways: {
            self.identityUserIsLoading = false
        }
    }

    private func fetchAccountStorageUsage() async throws -> VOStorage.Usage? {
        try await storageClient?.fetchAccountUsage()
    }

    func fetchAccountStorageUsage() {
        var storageUsage: VOStorage.Usage?
        withErrorHandling {
            storageUsage = try await self.fetchAccountStorageUsage()
            return true
        } before: {
            self.storageUsageIsLoading = true
        } success: {
            self.storageUsage = storageUsage
        } failure: { message in
            self.storageUsageError = message
        } anyways: {
            self.storageUsageIsLoading = false
        }
    }

    // MARK: - Update

    func updateEmail(_ email: String) async throws -> VOIdentityUser.Entity? {
        try await identityUserClient?.updateEmailRequest(.init(email: email))
    }

    func updateFullName(_ fullName: String) async throws -> VOIdentityUser.Entity? {
        try await identityUserClient?.updateFullName(.init(fullName: fullName))
    }

    func updatePassword(current: String, new: String) async throws -> VOIdentityUser.Entity? {
        try await identityUserClient?.updatePassword(.init(currentPassword: current, newPassword: new))
    }

    func deleteAccount(password: String) async throws {
        try await identityUserClient?.delete(.init(password: password))
    }

    // MARK: - Timer

    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.identityUser != nil {
                Task {
                    let user = try await self.fetchIdentityUser()
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
