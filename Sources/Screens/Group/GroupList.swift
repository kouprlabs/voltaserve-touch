import Combine
import SwiftUI
import VoltaserveCore

struct GroupList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showNew = false

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
                                    GroupOverview(group)
                                } label: {
                                    GroupRow(group)
                                        .onAppear {
                                            onListItemAppear(group.id)
                                        }
                                }
                            }
                            if groupStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Groups")
                .searchable(text: $groupStore.searchText)
                .refreshable {
                    groupStore.fetchList(replace: true)
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
                    GroupNew()
                }
                .onChange(of: groupStore.searchText) {
                    groupStore.searchPublisher.send($1)
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $groupStore.showError,
            title: groupStore.errorTitle,
            message: groupStore.errorMessage
        )
        .onAppear {
            groupStore.clear()
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
        .onChange(of: groupStore.query) {
            groupStore.clear()
            groupStore.fetchList()
        }
    }

    private func onAppearOrChange() {
        fetchData()
        startTimers()
    }

    private func fetchData() {
        groupStore.fetchList(replace: true)
    }

    private func startTimers() {
        groupStore.startTimer()
    }

    private func stopTimers() {
        groupStore.stopTimer()
    }

    private func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            groupStore.fetchList()
        }
    }
}
