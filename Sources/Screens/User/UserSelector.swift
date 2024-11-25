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

struct UserSelector: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing, ListItemScrollable {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var userStore = UserStore()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    private let onCompletion: ((VOUser.Entity) -> Void)?
    private let groupID: String?
    private let organizationID: String?

    init(
        groupID: String? = nil,
        organizationID: String? = nil,
        onCompletion: ((VOUser.Entity) -> Void)? = nil
    ) {
        self.groupID = groupID
        self.organizationID = organizationID
        self.onCompletion = onCompletion
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
                            Text("There are no users.")
                        } else {
                            List {
                                ForEach(entities, id: \.id) { user in
                                    Button {
                                        dismiss()
                                        onCompletion?(user)
                                    } label: {
                                        UserRow(
                                            user,
                                            pictureURL: userStore.urlForPicture(
                                                user.id,
                                                fileExtension: user.picture?.fileExtension
                                            )
                                        )
                                        .onAppear {
                                            onListItemAppear(user.id)
                                        }
                                    }
                                }
                            }
                            .searchable(text: $searchText)
                            .onChange(of: searchText) {
                                userStore.searchPublisher.send($1)
                            }
                        }
                    }
                    .refreshable {
                        userStore.fetchNextPage(replace: true)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            if userStore.entitiesIsLoading {
                                ProgressView()
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Select User")
        .onAppear {
            if let groupID {
                userStore.groupID = groupID
            } else if let organizationID {
                userStore.organizationID = organizationID
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
        userStore.entitiesIsLoadingFirstTime
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
