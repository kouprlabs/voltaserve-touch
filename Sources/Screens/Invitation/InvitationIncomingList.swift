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

struct InvitationIncomingList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @State private var showInfo = false
    @State private var invitation: VOInvitation.Entity?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = invitationStore.entities {
                    Group {
                        if entities.isEmpty {
                            Text("There are no invitations.")
                        } else {
                            List {
                                ForEach(entities, id: \.id) { invitation in
                                    NavigationLink {
                                        InvitationOverview(
                                            invitation,
                                            invitationStore: invitationStore,
                                            isAcceptableDeclinable: true
                                        )
                                    } label: {
                                        InvitationIncomingRow(invitation)
                                            .onAppear {
                                                onListItemAppear(invitation.id)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        invitationStore.fetchNextPage(replace: true)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Invitations")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if invitationStore.entitiesIsLoading, invitationStore.entities != nil {
                    ProgressView()
                }
            }
        }
        .onAppear {
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
        invitationStore.entitiesIsLoadingFirstTime
    }

    var error: String? {
        invitationStore.entitiesError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        invitationStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        invitationStore.startTimer()
    }

    func stopTimers() {
        invitationStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        invitationStore.token = token
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if invitationStore.isEntityThreshold(id) {
            invitationStore.fetchNextPage()
        }
    }
}
