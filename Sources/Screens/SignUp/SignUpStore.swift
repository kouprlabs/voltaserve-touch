// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import Foundation

@MainActor
public class SignUpStore: ObservableObject {
    @Published public var passwordRequirements: VOAccount.PasswordRequirements?
    @Published public var passwordRequirementsIsLoading = false
    @Published public var passwordRequirementsError: String?
    private var timer: Timer?
    private var accountClient: VOAccount = .init(baseURL: Config.shared.idpURL)

    // MARK: - Fetch

    public func fetchPasswordRequirements() {
        var passwordRequirements: VOAccount.PasswordRequirements?
        withErrorHandling {
            passwordRequirements = try await self.accountClient.fetchPasswordRequirements()
            return true
        } before: {
            self.passwordRequirementsIsLoading = true
        } success: {
            self.passwordRequirements = passwordRequirements
            self.passwordRequirementsError = nil
        } failure: { message in
            self.passwordRequirementsError = message
        } anyways: {
            self.passwordRequirementsIsLoading = false
        }
    }

    // MARK: - Update

    public func createAccount(_ options: VOAccount.CreateOptions) async throws -> VOIdentityUser.Entity {
        return try await accountClient.create(options)
    }

    // MARK: - Sync

    public func syncPasswordRequirements() async throws {
        if await passwordRequirements != nil {
            let passwordRequirements = try await self.accountClient.fetchPasswordRequirements()
            await MainActor.run {
                self.passwordRequirements = passwordRequirements
                self.passwordRequirementsError = nil
            }
        }
    }

    // MARK: - Timer

    public func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            Task.detached {
                try await self.syncPasswordRequirements()
            }
        }
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
