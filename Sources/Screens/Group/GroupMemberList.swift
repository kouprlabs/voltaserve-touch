import Combine
import SwiftUI
import VoltaserveCore

struct GroupMemberList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var groupStore: GroupStore
    @StateObject private var userStore = UserStore()
    @State private var showAddMember = false
    @State private var searchText = ""
    @State private var showError = false

    init(groupStore: GroupStore) {
        self.groupStore = groupStore
    }

    var body: some View {
        VStack {
            if let entities = userStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { member in
                                UserRow(member)
                                    .onAppear {
                                        onListItemAppear(member.id)
                                    }
                            }
                            if userStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .onChange(of: userStore.searchText) {
                            userStore.searchPublisher.send($1)
                        }
                    }
                }
                .refreshable {
                    userStore.fetchList(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddMember = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddMember) {
                    GroupMemberAdd(groupStore: groupStore)
                }
                .voErrorAlert(
                    isPresented: $showError,
                    title: userStore.errorTitle,
                    message: userStore.errorMessage
                )
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Members")
        .onAppear {
            if let group = groupStore.current {
                userStore.groupID = group.id
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
            userStore.fetchList()
        }
        .sync($userStore.searchText, with: $searchText)
        .sync($userStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        userStore.fetchList(replace: true)
    }

    private func startTimers() {
        userStore.startTimer()
    }

    private func stopTimers() {
        userStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if userStore.isLast(id) {
            userStore.fetchList()
        }
    }
}
