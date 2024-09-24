import SwiftUI
import VoltaserveCore

struct AccountSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private let onDelete: (() -> Void)?

    init(onDelete: (() -> Void)? = nil) {
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
                        NavigationLink(destination: AccountEditFullName()) {
                            HStack {
                                Text("Full name")
                                Spacer()
                                Text(user.fullName)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Credentials")) {
                        NavigationLink(destination: AccountEditEmail()) {
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(user.email)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                        NavigationLink(destination: AccountEditPassword()) {
                            HStack {
                                Text("Password")
                                Spacer()
                                Text(String(repeating: "•", count: 10))
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Advanced")) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
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
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .onAppear {
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            accountStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
    }

    private func onAppearOrChange() {
        fetchUser()
        accountStore.startTimer()
    }

    private func fetchUser() {
        var user: VOIdentityUser.Entity?
        withErrorHandling {
            user = try await accountStore.fetchUser()
            return true
        } success: {
            accountStore.identityUser = user
        } failure: { message in
            errorTitle = "Error: Fetching User"
            errorMessage = message
            showError = true
        }
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            try await accountStore.deleteAccount()
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
