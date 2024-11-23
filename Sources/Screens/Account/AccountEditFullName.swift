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
import VoltaserveCore

struct AccountEditFullName: View, LoadStateProvider, FormValidatable, ErrorPresentable {
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isSaving = false

    init(accountStore: AccountStore) {
        self.accountStore = accountStore
    }

    var body: some View {
        if isLoading {
            ProgressView()
        } else if let error {
            VOErrorMessage(error)
        } else {
            if let identityUser = accountStore.identityUser {
                Form {
                    TextField("Full Name", text: $value)
                        .disabled(isSaving)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Change Full Name")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Button("Save") {
                                performSave()
                            }
                            .disabled(!isValid())
                        }
                    }
                }
                .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
                .onAppear {
                    value = identityUser.fullName
                }
                .onChange(of: accountStore.identityUser) { _, newUser in
                    if let newUser {
                        value = newUser.fullName
                    }
                }
            }
        }
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        isSaving = true
        withErrorHandling {
            _ = try await accountStore.updateFullName(normalizedValue)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isSaving = false
        }
    }

    // MARK: - ErrorPresentable

    @State var errorIsPresented = false
    @State var errorMessage: String?

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        accountStore.identityUserIsLoading
    }

    var error: String? {
        accountStore.identityUserError
    }

    // MARK: - FormValidatable

    func isValid() -> Bool {
        if let identityUser = accountStore.identityUser {
            return !normalizedValue.isEmpty && normalizedValue != identityUser.fullName
        }
        return false
    }
}
