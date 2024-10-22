import SwiftUI
import VoltaserveCore

struct AccountOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var accountStore = AccountStore()
    @StateObject private var invitationStore = InvitationStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showDelete = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
            VStack {
                if accountStore.identityUser == nil ||
                    accountStore.storageUsage == nil {
                    ProgressView()
                } else if let user = accountStore.identityUser {
                    VOAvatar(
                        name: user.fullName,
                        size: 100,
                        url: accountStore.urlForUserPicture(
                            user.id,
                            fileExtension: user.picture?.fileExtension
                        )
                    )
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
                            NavigationLink(destination: AccountSettings(accountStore: accountStore) {
                                dismiss()
                                performSignOut()
                            }) {
                                Label("Settings", systemImage: "gear")
                            }
                            NavigationLink(destination: InvitationIncomingList()) {
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
        .voErrorAlert(
            isPresented: $showError,
            title: accountStore.errorTitle,
            message: accountStore.errorMessage
        )
        .onAppear {
            accountStore.tokenStore = tokenStore
            if let token = tokenStore.token {
                assignTokenToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
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
        accountStore.fetchAccountStorageUsage()
        invitationStore.fetchIncomingCount()
    }

    private func startTimers() {
        accountStore.startTimer()
        accountStore.startTimer()
        invitationStore.startTimer()
    }

    private func stopTimers() {
        accountStore.stopTimer()
        invitationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        accountStore.token = token
        invitationStore.token = token
    }

    private func performSignOut() {
        tokenStore.token = nil
        tokenStore.deleteFromKeychain()
        dismiss()
    }
}
