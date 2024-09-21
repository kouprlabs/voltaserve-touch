import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showNew = false

    var body: some View {
        NavigationStack {
            if let entities = organizationStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { organization in
                                NavigationLink {
                                    OrganizationOverview(organization)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationTitle(organization.name)
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
                .searchable(text: $organizationStore.searchText)
                .refreshable {
                    organizationStore.fetchList(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showNew = true
                        } label: {
                            Label("New Organization", systemImage: "plus")
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
            isPresented: $organizationStore.showError,
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
            organizationStore.stopTimer()
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
    }

    private func onAppearOrChange() {
        organizationStore.fetchList(replace: true)
        organizationStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            organizationStore.fetchList()
        }
    }
}
