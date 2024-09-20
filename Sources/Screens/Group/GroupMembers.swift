import Combine
import SwiftUI
import VoltaserveCore

struct GroupMembers: View {
    @StateObject private var userStore = UserStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAddMember = false
    @State private var showSettings = false

    var body: some View {
        VStack {
            if let entities = userStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { member in
                                VOUserRow(member)
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
                            Label("Add Member", systemImage: "person.badge.plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    GroupSettings {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .sheet(isPresented: $showAddMember) {
                    Text("Add Member")
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
