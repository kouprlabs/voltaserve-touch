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
    @Published public var passwordRequirementsIsLoading: Bool = false
    @Published public var passwordRequirementsError: String?
    private var timer: Timer?
    private var accountClient: VOAccount = .init(baseURL: Config.production.idpURL)

    // MARK: - Fetch

    private func fetchPasswordRequirements() async throws -> VOAccount.PasswordRequirements? {
        return try await accountClient.fetchPasswordRequirements()
    }

    public func fetchPasswordRequirements() {
        var passwordRequirements: VOAccount.PasswordRequirements?
        withErrorHandling {
            passwordRequirements = try await self.fetchPasswordRequirements()
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

    public func signUp(_ options: VOAccount.CreateOptions) async throws -> VOIdentityUser.Entity {
        return try await accountClient.create(options)
    }

    // MARK: - Timer

    public func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if self.passwordRequirements != nil {
                Task {
                    let passwordRequirements = try await self.fetchPasswordRequirements()
                    if let passwordRequirements {
                        DispatchQueue.main.async {
                            self.passwordRequirements = passwordRequirements
                            self.passwordRequirementsError = nil
                        }
                    }
                }
            }
        }
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
