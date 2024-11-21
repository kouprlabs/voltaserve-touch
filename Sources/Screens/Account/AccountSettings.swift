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

struct AccountSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showDeleteNotice = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var password = ""
    @State private var isDeleting = false
    private let onDelete: (() -> Void)?

    init(accountStore: AccountStore, onDelete: (() -> Void)? = nil) {
        self.accountStore = accountStore
        self.onDelete = onDelete
    }

    var body: some View {
        VStack {
            if accountStore.identityUser == nil ||
                accountStore.storageUsage == nil {
                ProgressView()
            } else if let user = accountStore.identityUser {
                Form {
                    Section(header: VOSectionHeader("Basics")) {
                        NavigationLink(destination: AccountEditFullName(accountStore: accountStore)) {
                            HStack {
                                Text("Full name")
                                Spacer()
                                Text(user.fullName)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Credentials")) {
                        NavigationLink(destination: AccountEditEmail(accountStore: accountStore)) {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(user.pendingEmail ?? user.email)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                        if user.pendingEmail != nil {
                            HStack(spacing: VOMetrics.spacingXs) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(Color.yellow400)
                                Text("Please check your inbox to confirm your email.")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.footnote)
                        }
                        NavigationLink(destination: AccountEditPassword(accountStore: accountStore)) {
                            HStack {
                                Text("Password")
                                Spacer()
                                Text(String(repeating: "•", count: 10))
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Delete Account")) {
                        SecureField("Type your password to confirm", text: $password)
                            .disabled(isDeleting)
                        Button(role: .destructive) {
                            if password.isEmpty {
                                showDeleteNotice = true
                            } else {
                                showDeleteConfirmation = true
                            }
                        } label: {
                            HStack {
                                Text("Delete Account")
                                if isDeleting {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isDeleting)
                        .confirmationDialog("Delete Account", isPresented: $showDeleteConfirmation) {
                            Button("Delete Permanently", role: .destructive) {
                                performDelete()
                            }
                        } message: {
                            Text("Are you sure want to delete your account?")
                        }
                        .alert("Missing Password Confirmation", isPresented: $showDeleteNotice) {
                            Button("OK") {}
                        } message: {
                            Text("You need to enter your password to confirm the account deletion.")
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .onAppear {
            accountStore.tokenStore = tokenStore
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .sync($accountStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        accountStore.fetchUser()
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            try await accountStore.deleteAccount(password: password)
            return true
        } success: {
            dismiss()
            onDelete?()
        } failure: { message in
            errorTitle = "Error: Deleting Account"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }
}
