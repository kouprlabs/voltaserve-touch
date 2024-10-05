import Combine
import SwiftUI
import VoltaserveCore

struct GroupMemberList: View {
    @StateObject private var userStore = UserStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showAddMember = false
    @State private var searchText = ""
    @State private var showError = false

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
                    }
                }
                .searchable(text: $searchText)
                .refreshable {
                    userStore.fetchList(replace: true)
                }
                .onChange(of: userStore.searchText) {
                    userStore.searchPublisher.send($1)
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
                    GroupMemberAdd()
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
        .onChange(of: userStore.query) {
            userStore.clear()
            userStore.fetchList()
        }
        .sync($userStore.searchText, with: $searchText)
        .sync($userStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
        startTimers()
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
