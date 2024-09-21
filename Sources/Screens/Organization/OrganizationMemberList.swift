import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationMemberList: View {
    @StateObject private var userStore = UserStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showInviteMembers = false

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
                        NavigationLink {
                            OrganizationMemberInvite()
                        } label: {
                            Label("Invite Members", systemImage: "person.badge.plus")
                        }
                    }
                }
                .sheet(isPresented: $showInviteMembers) {
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
                if let organization = organizationStore.current {
                    userStore.organizationID = organization.id
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
