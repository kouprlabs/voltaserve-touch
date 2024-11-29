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

struct OrganizationList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var organizationStore = OrganizationStore()
    @State private var createIsPresented = false
    @State private var overviewIsPresented = false
    @State private var searchText = ""
    @State private var newOrganization: VOOrganization.Entity?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    if let entities = organizationStore.entities {
                        Group {
                            if entities.count == 0 {
                                Text("There are no organizations.")
                            } else {
                                List {
                                    ForEach(entities, id: \.id) { organization in
                                        NavigationLink {
                                            OrganizationOverview(organization, organizationStore: organizationStore)
                                        } label: {
                                            OrganizationRow(organization)
                                                .onAppear {
                                                    onListItemAppear(organization.id)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            organizationStore.fetchNextPage(replace: true)
                        }
                        .searchable(text: $searchText)
                        .onChange(of: searchText) {
                            organizationStore.searchPublisher.send($1)
                        }
                    }
                }
            }
            .navigationTitle("Organizations")
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
                OrganizationCreate(organizationStore: organizationStore) { newOrganization in
                    self.newOrganization = newOrganization
                    overviewIsPresented = true
                }
            }
            .navigationDestination(isPresented: $overviewIsPresented) {
                if let newOrganization {
                    OrganizationOverview(newOrganization, organizationStore: organizationStore)
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
        .onChange(of: organizationStore.query) {
            organizationStore.clear()
            organizationStore.fetchNextPage()
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        organizationStore.entitiesIsLoadingFirstTime
    }

    var error: String? {
        organizationStore.entitiesError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        organizationStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        organizationStore.startTimer()
    }

    func stopTimers() {
        organizationStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        organizationStore.token = token
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if organizationStore.isEntityThreshold(id) {
            organizationStore.fetchNextPage()
        }
    }
}
