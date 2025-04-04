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

struct AccountDelete: View, ErrorPresentable {
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var confirmationIsPresented = false
    private let onDelete: (() -> Void)?

    public init(accountStore: AccountStore, onDelete: (() -> Void)? = nil) {
        self.accountStore = accountStore
        self.onDelete = onDelete
    }

    var body: some View {
        Button(role: .destructive) {
            confirmationIsPresented = true
        } label: {
            VOFormButtonLabel("Delete Account and Data", isLoading: isProcessing)
        }
        .disabled(isProcessing)
        .confirmationDialog("Delete Account and Data", isPresented: $confirmationIsPresented) {
            Button("Delete Account and Data", role: .destructive) {
                performDelete()
            }
        } message: {
            Text("Are you sure want to delete your account and data?")
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performDelete() {
        withErrorHandling {
            try await accountStore.deleteAccount()
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
            onDelete?()
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
}
