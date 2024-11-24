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

struct AccountOverview: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var accountStore = AccountStore()
    @StateObject private var invitationStore = InvitationStore()
    @Environment(\.dismiss) private var dismiss
    @State private var deleteIsPresented = false

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    if let identityUser = accountStore.identityUser {
                        VOAvatar(
                            name: identityUser.fullName,
                            size: 100,
                            url: accountStore.urlForUserPicture(
                                identityUser.id,
                                fileExtension: identityUser.picture?.fileExtension
                            )
                        )
                        .padding()
                    }
                    Form {
                        Section(header: VOSectionHeader("Storage Usage")) {
                            VStack(alignment: .leading) {
                                if let storageUsage = accountStore.storageUsage {
                                    // swift-format-ignore
                                    // swiftlint:disable:next line_length
                                    Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                                    ProgressView(value: Double(storageUsage.percentage) / 100.0)
                                }
                            }
                        }
                        Section {
                            NavigationLink(
                                destination: AccountSettings(accountStore: accountStore) {
                                    dismiss()
                                    performSignOut()
                                }
                            ) {
                                Label("Settings", systemImage: "gear")
                            }
                            NavigationLink(destination: InvitationIncomingList()) {
                                HStack {
                                    Label("Invitations", systemImage: "paperplane")
                                    Spacer()
                                    if let incomingCount = invitationStore.incomingCount, incomingCount > 0 {
                                        VONumberBadge(incomingCount)
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
    }

    private func performSignOut() {
        tokenStore.token = nil
        tokenStore.deleteFromKeychain()
        dismiss()
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        accountStore.identityUserIsLoading || accountStore.storageUsageIsLoading
            || invitationStore.incomingCountIsLoading
    }

    var error: String? {
        accountStore.identityUserError ?? accountStore.storageUsageError ?? invitationStore.incomingCountError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        accountStore.fetchIdentityUser()
        accountStore.fetchAccountStorageUsage()
        invitationStore.fetchIncomingCount()
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        accountStore.startTimer()
        invitationStore.startTimer()
    }

    func stopTimers() {
        accountStore.stopTimer()
        invitationStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        accountStore.token = token
        invitationStore.token = token
    }
}
