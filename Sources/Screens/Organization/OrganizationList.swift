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

struct OrganizationList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var organizationStore = OrganizationStore()
    @State private var showCreate = false
    @State private var showOverview = false
    @State private var showError = false
    @State private var searchText = ""
    @State private var newOrganization: VOOrganization.Entity?

    var body: some View {
        NavigationStack {
            if let entities = organizationStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no organizations.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { organization in
                                NavigationLink {
                                    OrganizationOverview(
                                        organization, organizationStore: organizationStore)
                                } label: {
                                    OrganizationRow(organization)
                                        .onAppear {
                                            onListItemAppear(organization.id)
                                        }
                                }
                            }
                        }
                        .navigationTitle("Organizations")
                        .searchable(text: $searchText)
                        .onChange(of: organizationStore.searchText) {
                            organizationStore.searchPublisher.send($1)
                        }
                    }
                }
                .refreshable {
                    organizationStore.fetchNextPage(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showCreate = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if organizationStore.isLoading, organizationStore.entities != nil {
                            ProgressView()
                        }
                    }
                }
                .sheet(isPresented: $showCreate) {
                    OrganizationCreate(organizationStore: organizationStore) { newOrganization in
                        self.newOrganization = newOrganization
                        showOverview = true
                    }
                }
                .navigationDestination(isPresented: $showOverview) {
                    if let newOrganization {
                        OrganizationOverview(newOrganization, organizationStore: organizationStore)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: organizationStore.errorTitle,
            message: organizationStore.errorMessage
        )
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
        .sync($organizationStore.searchText, with: $searchText)
        .sync($organizationStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        organizationStore.fetchNextPage(replace: true)
    }

    private func startTimers() {
        organizationStore.startTimer()
    }

    private func stopTimers() {
        organizationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        organizationStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if organizationStore.isEntityThreshold(id) {
            organizationStore.fetchNextPage()
        }
    }
}
