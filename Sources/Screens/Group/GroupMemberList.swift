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

struct GroupMemberList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var groupStore: GroupStore
    @StateObject private var userStore = UserStore()
    @State private var showAddMember = false
    @State private var searchText = ""
    @State private var showError = false

    init(groupStore: GroupStore) {
        self.groupStore = groupStore
    }

    var body: some View {
        VStack {
            if let entities = userStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { member in
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
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddMember = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddMember) {
                    GroupMemberAdd(groupStore: groupStore)
                }
                .voErrorAlert(
                    isPresented: $showError,
                    title: userStore.errorTitle,
                    message: userStore.errorMessage
                )
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Members")
        .onAppear {
            if let group = groupStore.current {
                userStore.groupID = group.id
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
        .sync($userStore.searchText, with: $searchText)
        .sync($userStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        userStore.fetchNextPage(replace: true)
    }

    private func startTimers() {
        userStore.startTimer()
    }

    private func stopTimers() {
        userStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if userStore.isEntityThreshold(id) {
            userStore.fetchNextPage()
        }
    }
}
