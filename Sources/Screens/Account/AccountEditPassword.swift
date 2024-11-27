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

struct AccountEditPassword: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentValue = ""
    @State private var newValue = ""
    @State private var isProcessing = false

    init(accountStore: AccountStore) {
        self.accountStore = accountStore
    }

    var body: some View {
        Form {
            SecureField("Current Password", text: $currentValue)
                .disabled(isProcessing)
            SecureField("New Password", text: $newValue)
                .disabled(isProcessing)
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
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performSave() {
        withErrorHandling {
            _ = try await accountStore.updatePassword(current: currentValue, new: newValue)
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

    @State var errorIsPresented = false
    @State var errorMessage: String?

    // MARK: - FormValidatable

    func isValid() -> Bool {
        !currentValue.isEmpty && !newValue.isEmpty
    }
}
