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

public struct AccountEditFullName: View, LoadStateProvider, FormValidatable, ErrorPresentable {
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isProcessing = false

    public init(accountStore: AccountStore) {
        self.accountStore = accountStore
    }

    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let identityUser = accountStore.identityUser {
                    Form {
                        TextField("Full Name", text: $value)
                            .disabled(isProcessing)
                    }
                    .onAppear {
                        value = identityUser.fullName
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Change Full Name")
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
        .onChange(of: accountStore.identityUser) { _, newUser in
            if let newUser {
                value = newUser.fullName
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        withErrorHandling {
            _ = try await accountStore.updateFullName(.init(fullName: normalizedValue))
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

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        accountStore.identityUserIsLoading
    }

    public var error: String? {
        accountStore.identityUserError
    }

    // MARK: - FormValidatable

    public func isValid() -> Bool {
        if let identityUser = accountStore.identityUser {
            return !normalizedValue.isEmpty && normalizedValue != identityUser.fullName
        }
        return false
    }
}
