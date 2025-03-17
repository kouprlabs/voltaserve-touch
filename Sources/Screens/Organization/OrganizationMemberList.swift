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

public struct OrganizationMemberList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var organizationStore: OrganizationStore
    @StateObject private var userStore = UserStore()
    @State private var searchText = ""

    public init(organizationStore: OrganizationStore) {
        self.organizationStore = organizationStore
    }

    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = userStore.entities {
                    Group {
                        if entities.count == 0 {
                            Text("There are no users.")
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
                        }
                    }
                    .refreshable {
                        userStore.fetchNextPage(replace: true)
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) {
                        userStore.searchPublisher.send($1)
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

    public var isLoading: Bool {
        userStore.entitiesIsLoadingFirstTime
    }

    public var error: String? {
        userStore.entitiesError
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        userStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    public func startTimers() {
        userStore.startTimer()
    }

    public func stopTimers() {
        userStore.stopTimer()
    }

    // MARK: - TokenDistributing

    public func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }

    // MARK: - ListItemScrollable

    public func onListItemAppear(_ id: String) {
        if userStore.isEntityThreshold(id) {
            userStore.fetchNextPage()
        }
    }
}
