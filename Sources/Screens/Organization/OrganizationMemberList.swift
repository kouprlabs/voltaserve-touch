import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationMemberList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var organizationStore: OrganizationStore
    @StateObject private var userStore = UserStore()
    @State private var showInviteMembers = false
    @State private var showError = false
    @State private var searchText = ""

    init(organizationStore: OrganizationStore) {
        self.organizationStore = organizationStore
    }

    var body: some View {
        VStack {
            if let entities = userStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List(entities, id: \.id) { member in
                            UserRow(member)
                                .onAppear {
                                    onListItemAppear(member.id)
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
                        NavigationLink {
                            OrganizationMemberInvite(organizationStore: organizationStore)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showInviteMembers) {
                    Text("Add Member")
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
            if let organization = organizationStore.current {
                userStore.organizationID = organization.id
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
