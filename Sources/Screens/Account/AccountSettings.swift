import SwiftUI
import VoltaserveCore

struct AccountSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false

    var body: some View {
        NavigationView {
            VStack {
                if accountStore.identityUser == nil ||
                    accountStore.storageUsage == nil {
                    ProgressView()
                } else if let user = accountStore.identityUser {
                    VOAvatar(name: user.fullName, size: 100, base64Image: user.picture)
                        .padding()
                    Form {
                        Section(header: VOSectionHeader("Storage Usage")) {
                            VStack(alignment: .leading) {
                                if let storageUsage = accountStore.storageUsage {
                                    // swiftlint:disable:next line_length
                                    Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                                    ProgressView(value: Double(storageUsage.percentage) / 100.0)
                                } else {
                                    Text("Calculating…")
                                    ProgressView()
                                }
                            }
                        }
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
                            Button("Sign Out", role: .destructive) {
                                performSignOut()
                            }
                            .disabled(isDeleting)
                        }
                        Section(header: VOSectionHeader("Advanced")) {
                            Button(role: .destructive) {
                                showDelete = true
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
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Account")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isDeleting)
                }
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .alert("Delete Account", isPresented: $showDelete) {
            Button("Delete Permanently", role: .destructive) {
                performDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure want to delete your account?")
        }
        .onAppear {
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

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        fetchUser()
        fetchAccountStorageUsage()
    }

    private func fetchUser() {
        var user: VOIdentityUser.Entity?

        VOErrorResponse.withErrorHandling {
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

    private func fetchAccountStorageUsage() {
        var usage: VOStorage.Usage?

        VOErrorResponse.withErrorHandling {
            usage = try await accountStore.fetchAccountStorageUsage()
            return true
        } success: {
            accountStore.storageUsage = usage
        } failure: { message in
            errorTitle = "Error: Fetching Storage Usage"
            errorMessage = message
            showError = true
        }
    }

    private func performDelete() {
        isDeleting = true

        VOErrorResponse.withErrorHandling {
            try await accountStore.deleteAccount()
            return true
        } success: {
            performSignOut()
        } failure: { message in
            errorTitle = "Error: Deleting Account"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }

    private func performSignOut() {
        tokenStore.token = nil
        tokenStore.deleteFromKeychain()
        presentationMode.wrappedValue.dismiss()
    }
}
