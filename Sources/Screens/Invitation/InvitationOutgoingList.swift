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

struct InvitationOutgoingList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @StateObject private var organizationStore = OrganizationStore()
    @State private var showCreate = false
    @State private var invitation: VOInvitation.Entity?
    private let organizationID: String

    init(_ organizationID: String) {
        self.organizationID = organizationID
    }

    var body: some View {
        VStack {
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
                                        isDeletable: true
                                    )
                                } label: {
                                    InvitationOutgoingRow(invitation)
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
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Invitations")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                if invitationStore.entitiesIsLoading, invitationStore.entities != nil {
                    ProgressView()
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            InvitationCreate(organizationID)
        }
        .onAppear {
            invitationStore.organizationID = organizationID
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

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        invitationStore.fetchNextPage(replace: true)
    }

    private func startTimers() {
        invitationStore.startTimer()
        organizationStore.startTimer()
    }

    private func stopTimers() {
        invitationStore.stopTimer()
        organizationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        invitationStore.token = token
        organizationStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if invitationStore.isEntityThreshold(id) {
            invitationStore.fetchNextPage()
        }
    }
}
