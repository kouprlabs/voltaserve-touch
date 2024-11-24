// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationMemberList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var organizationStore: OrganizationStore
    @StateObject private var userStore = UserStore()
    @State private var showInviteMembers = false
    @State private var showError = false
    @State private var searchText = ""

    init(organizationStore: OrganizationStore) {
        self.organizationStore = organizationStore
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = userStore.entities {
                    Group {
                        if entities.count == 0 {
                            Text("There are no items.")
                        } else {
                            List(entities, id: \.id) { member in
                                UserRow(
                                    member,
                                    pictureURL: userStore.urlForPicture(
                                        member.id,
                                        fileExtension: member.picture?.fileExtension
                                    )
                                )
                                .onAppear {
                                    onListItemAppear(member.id)
                                }
                            }
                            .searchable(text: $searchText)
                            .onChange(of: userStore.searchText) {
                                userStore.searchPublisher.send($1)
                            }
                        }
                    }
                    .refreshable {
                        userStore.fetchNextPage(replace: true)
                    }
                    .sheet(isPresented: $showInviteMembers) {
                        Text("Add Member")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Members")
        .onAppear {
            if let organization = organizationStore.current {
                userStore.organizationID = organization.id
            }
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
        .onChange(of: userStore.query) {
            userStore.clear()
            userStore.fetchNextPage()
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        userStore.entities == nil
    }

    var error: String? {
        userStore.entitiesError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        userStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        userStore.startTimer()
    }

    func stopTimers() {
        userStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if userStore.isEntityThreshold(id) {
            userStore.fetchNextPage()
        }
    }
}
