import Combine
import SwiftUI
import VoltaserveCore

struct GroupList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var groupStore = GroupStore()
    @State private var showCreate = false
    @State private var showOverview = false
    @State private var showError = false
    @State private var searchText = ""
    @State private var newGroup: VOGroup.Entity?

    var body: some View {
        NavigationStack {
            if let entities = groupStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no groups.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { group in
                                NavigationLink {
                                    GroupOverview(group, groupStore: groupStore)
                                } label: {
                                    GroupRow(group)
                                        .onAppear {
                                            onListItemAppear(group.id)
                                        }
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .onChange(of: groupStore.searchText) {
                            groupStore.searchPublisher.send($1)
                        }
                    }
                }
                .navigationTitle("Groups")
                .refreshable {
                    groupStore.fetchNext(replace: true)
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
                        if groupStore.isLoading {
                            ProgressView()
                        }
                    }
                }
                .sheet(isPresented: $showCreate) {
                    GroupCreate(groupStore: groupStore) { newGroup in
                        self.newGroup = newGroup
                        showOverview = true
                    }
                }
                .navigationDestination(isPresented: $showOverview) {
                    if let newGroup {
                        GroupOverview(newGroup, groupStore: groupStore)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: groupStore.errorTitle,
            message: groupStore.errorMessage
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
        .onChange(of: groupStore.query) {
            groupStore.clear()
            groupStore.fetchNext()
        }
        .sync($groupStore.searchText, with: $searchText)
        .sync($groupStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        groupStore.fetchNext(replace: true)
    }

    private func startTimers() {
        groupStore.startTimer()
    }

    private func stopTimers() {
        groupStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        groupStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if groupStore.isEntityThreshold(id) {
            groupStore.fetchNext()
        }
    }
}
