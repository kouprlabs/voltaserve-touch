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

public struct UserSelector: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var userStore = UserStore()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    private let onCompletion: ((VOUser.Entity) -> Void)?
    private let groupID: String?
    private let organizationID: String?
    private let excludeGroupMembers: Bool?
    private let excludeMe: Bool?

    public init(
        organizationID: String? = nil,
        groupID: String? = nil,
        excludeGroupMembers: Bool? = nil,
        excludeMe: Bool? = nil,
        onCompletion: ((VOUser.Entity) -> Void)? = nil
    ) {
        self.organizationID = organizationID
        self.groupID = groupID
        self.excludeGroupMembers = excludeGroupMembers
        self.excludeMe = excludeMe
        self.onCompletion = onCompletion
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
                            Text("There are no items.")
                                .foregroundStyle(.secondary)
                        } else {
                            List(entities, id: \.id) { user in
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
        .navigationTitle("Select User")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if userStore.entitiesIsLoading {
                    ProgressView()
                }
            }
        }
        .onAppear {
            userStore.organizationID = organizationID
            userStore.groupID = groupID
            userStore.excludeGroupMembers = excludeGroupMembers
            userStore.excludeMe = excludeMe
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
