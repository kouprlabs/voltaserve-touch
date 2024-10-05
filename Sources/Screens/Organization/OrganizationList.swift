import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showNew = false
    @State private var showError = false
    @State private var searchText = ""

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
                                    OrganizationOverview(organization)
                                } label: {
                                    OrganizationRow(organization)
                                        .onAppear {
                                            onListItemAppear(organization.id)
                                        }
                                }
                            }
                            if organizationStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Organizations")
                .searchable(text: $searchText)
                .refreshable {
                    organizationStore.fetchList(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showNew = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showNew) {
                    OrganizationNew()
                }
                .onChange(of: organizationStore.searchText) {
                    organizationStore.searchPublisher.send($1)
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
            organizationStore.clear()
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: organizationStore.query) {
            organizationStore.clear()
            organizationStore.fetchList()
        }
        .sync($organizationStore.searchText, with: $searchText)
        .sync($organizationStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
        startTimers()
    }

    private func fetchData() {
        organizationStore.fetchList(replace: true)
    }

    private func startTimers() {
        organizationStore.startTimer()
    }

    private func stopTimers() {
        organizationStore.stopTimer()
    }

    private func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            organizationStore.fetchList()
        }
    }
}
