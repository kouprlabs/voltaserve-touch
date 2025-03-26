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

public struct InvitationOutgoingList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @StateObject private var organizationStore = OrganizationStore()
    @State private var createIsPresented = false
    @State private var invitation: VOInvitation.Entity?
    private let organizationID: String

    public init(_ organizationID: String) {
        self.organizationID = organizationID
    }

    public var body: some View {
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
                            List(entities, id: \.id) { invitation in
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
                    .refreshable {
                        invitationStore.fetchNextPage(replace: true)
                    }
                }
            }
        }
        .navigationTitle("Invitations")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    createIsPresented = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $createIsPresented) {
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

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        invitationStore.entitiesIsLoadingFirstTime
    }

    public var error: String? {
        invitationStore.entitiesError
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        invitationStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    public func startTimers() {
        invitationStore.startTimer()
        organizationStore.startTimer()
    }

    public func stopTimers() {
        invitationStore.stopTimer()
        organizationStore.stopTimer()
    }

    // MARK: - TokenDistributing

    public func assignTokenToStores(_ token: VOToken.Value) {
        invitationStore.token = token
        organizationStore.token = token
    }

    // MARK: - ListItemScrollable

    public func onListItemAppear(_ id: String) {
        if invitationStore.isEntityThreshold(id) {
            invitationStore.fetchNextPage()
        }
    }
}
