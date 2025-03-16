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

struct MurphOverview: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var accountStore = AccountStore()
    @StateObject private var invitationStore = InvitationStore()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("What can I do for you?")
            }
            .navigationTitle("Murph")
            .accountToolbar(accountStore: accountStore, invitationStore: invitationStore)
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
    
    // MARK: - LoadStateProvider

    var isLoading: Bool {
        accountStore.identityUserIsLoading || invitationStore.incomingCountIsLoading
    }

    var error: String? {
        accountStore.identityUserError ?? invitationStore.incomingCountError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        accountStore.fetchIdentityUser()
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
