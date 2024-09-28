import Combine
import SwiftUI
import VoltaserveCore

struct GroupMemberList: View {
    @StateObject private var userStore = UserStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showAddMember = false

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
                .searchable(text: $userStore.searchText)
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
                    isPresented: $userStore.showError,
                    title: userStore.errorTitle,
                    message: userStore.errorMessage
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if let token = tokenStore.token {
                userStore.token = token
                if let group = groupStore.current {
                    userStore.groupID = group.id
                }
                onAppearOrChange()
            }
        }
        .onDisappear {
            userStore.stopTimer()
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
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Members")
    }

    private func onAppearOrChange() {
        userStore.fetchList(replace: true)
        userStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if userStore.isLast(id) {
            userStore.fetchList()
        }
    }
}
