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
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { group in
                                NavigationLink {
                                    GroupOverview(group)
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationTitle(group.name)
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
                            Label("New Group", systemImage: "plus")
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
            groupStore.stopTimer()
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
        groupStore.fetchList(replace: true)
        groupStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            groupStore.fetchList()
        }
    }
}
