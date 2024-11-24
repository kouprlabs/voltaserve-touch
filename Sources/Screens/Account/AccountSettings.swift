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

struct AccountSettings: View, ViewDataProvider, LoadStateProvider, ErrorPresentable {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var deleteConfirmationIsPresented = false
    @State private var deleteNoticeIsPresented = false
    @State private var password = ""
    @State private var isDeleting = false
    private let onDelete: (() -> Void)?

    init(accountStore: AccountStore, onDelete: (() -> Void)? = nil) {
        self.accountStore = accountStore
        self.onDelete = onDelete
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else if let identityUser = accountStore.identityUser {
                Form {
                    Section(header: VOSectionHeader("Basics")) {
                        NavigationLink(destination: AccountEditFullName(accountStore: accountStore))
                        {
                            HStack {
                                Text("Full name")
                                Spacer()
                                Text(identityUser.fullName)
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
                                Text(identityUser.pendingEmail ?? identityUser.email)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                        if identityUser.pendingEmail != nil {
                            HStack(spacing: VOMetrics.spacingXs) {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(Color.yellow400)
                                Text("Please check your inbox to confirm your email.")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.footnote)
                        }
                        NavigationLink(destination: AccountEditPassword(accountStore: accountStore))
                        {
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
                                deleteNoticeIsPresented = true
                            } else {
                                deleteConfirmationIsPresented = true
                            }
                        } label: {
                            VOFormButtonLabel("Delete Account", isLoading: isDeleting)
                        }
                        .disabled(isDeleting)
                        .confirmationDialog(
                            "Delete Account", isPresented: $deleteConfirmationIsPresented
                        ) {
                            Button("Delete Permanently", role: .destructive) {
                                performDelete()
                            }
                        } message: {
                            Text("Are you sure want to delete your account?")
                        }
                        .confirmationDialog(
                            "Missing Password Confirmation",
                            isPresented: $deleteNoticeIsPresented
                        ) {
                        } message: {
                            Text("You need to enter your password to confirm the account deletion.")
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
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
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isDeleting = false
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

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        accountStore.fetchIdentityUser()
    }
}
