// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI

public struct AccountEditPassword: View, FormValidatable, ViewDataProvider, LoadStateProvider, ErrorPresentable {
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentValue = ""
    @State private var newValue = ""
    @State private var isProcessing = false

    public init(accountStore: AccountStore) {
        self.accountStore = accountStore
    }

    public var body: some View {
        Form {
            SecureField("Current Password", text: $currentValue)
                .disabled(isProcessing)
            SecureField("New Password", text: $newValue)
                .disabled(isProcessing)
            if let passwordRequirements = accountStore.passwordRequirements {
                VStack(alignment: .listRowSeparatorLeading) {
                    PasswordHint(
                        "\(passwordRequirements.minLength) characters.",
                        isFulfilled: newValue.hasMinLength(passwordRequirements.minLength))
                    PasswordHint(
                        "\(passwordRequirements.minLowercase) lowercase character.",
                        isFulfilled: newValue.hasMinLowerCase(passwordRequirements.minLowercase))
                    PasswordHint(
                        "\(passwordRequirements.minUppercase) uppercase character.",
                        isFulfilled: newValue.hasMinUpperCase(passwordRequirements.minUppercase))
                    PasswordHint(
                        "\(passwordRequirements.minNumbers) number.",
                        isFulfilled: newValue.hasMinNumbers(passwordRequirements.minNumbers))
                    PasswordHint(
                        "\(passwordRequirements.minSymbols) special character(s) (!#$%).",
                        isFulfilled: newValue.hasMinSymbols(passwordRequirements.minSymbols))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Change Password")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isProcessing {
                    ProgressView()
                } else {
                    Button("Save") {
                        performSave()
                    }
                    .disabled(!isValid())
                }
            }
        }
        .onAppear {
            onAppearOrChange()
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performSave() {
        withErrorHandling {
            _ = try await accountStore.updatePassword(
                .init(
                    currentPassword: currentValue,
                    newPassword: newValue
                )
            )
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented = false
    @State public var errorMessage: String?

    // MARK: - FormValidatable

    public func isValid() -> Bool {
        !currentValue.isEmpty && !newValue.isEmpty
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        accountStore.fetchPasswordRequirements()
    }

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        accountStore.passwordRequirementsIsLoading
    }

    public var error: String? {
        accountStore.passwordRequirementsError
    }
}
