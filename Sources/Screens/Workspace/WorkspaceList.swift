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

struct WorkspaceList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing, ListItemScrollable {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var workspaceStore = WorkspaceStore()
    @StateObject private var accountStore = AccountStore()
    @StateObject private var invitationStore = InvitationStore()
    @Environment(\.dismiss) private var dismiss
    @State private var accountIsPresented = false
    @State private var createIsPresented = false
    @State private var overviewIsPresented = false
    @State private var newWorkspace: VOWorkspace.Entity?

    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = workspaceStore.entities {
                    Group {
                        if entities.count == 0 {
                            Text("There are no workspaces.")
                        } else {
                            List {
                                ForEach(entities, id: \.id) { workspace in
                                    NavigationLink {
                                        WorkspaceOverview(workspace, workspaceStore: workspaceStore)
                                    } label: {
                                        WorkspaceRow(workspace)
                                            .onAppear {
                                                onListItemAppear(workspace.id)
                                            }
                                    }
                                }
                            }
                            .searchable(text: $workspaceStore.searchText)
                            .onChange(of: workspaceStore.searchText) {
                                workspaceStore.searchPublisher.send($1)
                            }
                        }
                    }
                    .navigationTitle("Home")
                    .refreshable {
                        workspaceStore.fetchNextPage(replace: true)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                accountButton
                                    .padding(.trailing, VOMetrics.spacingXs)
                            } else {
                                accountButton
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                createIsPresented = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            if workspaceStore.entitiesIsLoading {
                                ProgressView()
                            }
                        }
                    }
                    .sheet(isPresented: $createIsPresented) {
                        WorkspaceCreate(workspaceStore: workspaceStore) { newWorkspace in
                            self.newWorkspace = newWorkspace
                            overviewIsPresented = true
                        }
                    }
                    .sheet(isPresented: $accountIsPresented) {
                        AccountOverview()
                    }
                    .navigationDestination(isPresented: $overviewIsPresented) {
                        if let newWorkspace {
                            WorkspaceOverview(newWorkspace, workspaceStore: workspaceStore)
                        }
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
        .onChange(of: workspaceStore.query) {
            workspaceStore.clear()
            workspaceStore.fetchNextPage()
        }
    }

    private var accountButton: some View {
        ZStack {
            Button {
                accountIsPresented.toggle()
            } label: {
                if let identityUser = accountStore.identityUser {
                    VOAvatar(
                        name: identityUser.fullName,
                        size: 30,
                        url: accountStore.urlForUserPicture(
                            identityUser.id,
                            fileExtension: identityUser.picture?.fileExtension
                        )
                    )
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            if let count = invitationStore.incomingCount, count > 0 {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 14, y: -11)
            }
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        workspaceStore.entitiesIsLoadingFirstTime || accountStore.identityUserIsLoading
            || invitationStore.incomingCountIsLoading
    }

    var error: String? {
        workspaceStore.entitiesError ?? accountStore.identityUserError ?? invitationStore.incomingCountError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        workspaceStore.fetchNextPage(replace: true)
        accountStore.fetchIdentityUser()
        invitationStore.fetchIncomingCount()
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        workspaceStore.startTimer()
        accountStore.startTimer()
        invitationStore.startTimer()
    }

    func stopTimers() {
        workspaceStore.stopTimer()
        accountStore.stopTimer()
        invitationStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        workspaceStore.token = token
        accountStore.token = token
        invitationStore.token = token
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if workspaceStore.isEntityThreshold(id) {
            workspaceStore.fetchNextPage()
        }
    }
}
