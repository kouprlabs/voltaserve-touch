import SwiftUI
import VoltaserveCore

struct AccountOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var accountStore: AccountStore
    @EnvironmentObject private var invitationStore: InvitationStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
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
                        Section {
                            NavigationLink(destination: AccountSettings {
                                dismiss()
                                performSignOut()
                            }) {
                                Label("Settings", systemImage: "gear")
                            }
                            NavigationLink(destination: InvitationListIncoming()) {
                                HStack {
                                    Label("Invitations", systemImage: "paperplane")
                                    Spacer()
                                    if let count = invitationStore.incomingCount, count > 0 {
                                        VONumberBadge(count)
                                    }
                                }
                            }
                        }
                        Section {
                            Button("Sign Out", role: .destructive) {
                                performSignOut()
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Account")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
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
        fetchData()
        accountStore.startTimer()
    }

    private func fetchData() {
        fetchUser()
        fetchAccountStorageUsage()
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

    private func fetchAccountStorageUsage() {
        var usage: VOStorage.Usage?
        withErrorHandling {
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

    private func performSignOut() {
        tokenStore.token = nil
        tokenStore.deleteFromKeychain()
        dismiss()
    }
}
