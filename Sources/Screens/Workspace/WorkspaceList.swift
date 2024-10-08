import Combine
import SwiftUI
import VoltaserveCore

struct WorkspaceList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var workspaceStore = WorkspaceStore()
    @StateObject private var accountStore = AccountStore()
    @StateObject private var invitationStore = InvitationStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showAccount = false
    @State private var showNew = false
    @State private var showWorkspaceError = false
    @State private var showAccountError = false
    @State private var showInvitationError = false
    @State private var showTaskError = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            if let entities = workspaceStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no workspaces.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { workspace in
                                NavigationLink {
                                    WorkspaceOverview(workspace)
                                } label: {
                                    WorkspaceRow(workspace)
                                        .onAppear {
                                            onListItemAppear(workspace.id)
                                        }
                                }
                            }
                            if workspaceStore.isLoading {
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
                .onChange(of: workspaceStore.searchText) {
                    workspaceStore.searchPublisher.send($1)
                }
                .refreshable {
                    workspaceStore.fetchList(replace: true)
                }
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            accountButton
                                .padding(.trailing, VOMetrics.spacingXs)
                        } else {
                            accountButton
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showNew = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showNew) {
                    WorkspaceNew()
                }
                .sheet(isPresented: $showAccount) {
                    AccountOverview()
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showWorkspaceError,
            title: workspaceStore.errorTitle,
            message: workspaceStore.errorMessage
        )
        .voErrorAlert(
            isPresented: $showAccountError,
            title: accountStore.errorTitle,
            message: accountStore.errorMessage
        )
        .voErrorAlert(
            isPresented: $showInvitationError,
            title: invitationStore.errorTitle,
            message: invitationStore.errorMessage
        )
        .onAppear {
            accountStore.tokenStore = tokenStore
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
        .onChange(of: workspaceStore.query) {
            workspaceStore.clear()
            workspaceStore.fetchList()
        }
        .sync($workspaceStore.searchText, with: $searchText)
        .sync($workspaceStore.showError, with: $showWorkspaceError)
        .sync($accountStore.showError, with: $showAccountError)
        .sync($invitationStore.showError, with: $showInvitationError)
        .environmentObject(workspaceStore)
    }

    var accountButton: some View {
        ZStack {
            Button {
                showAccount.toggle()
            } label: {
                if let user = accountStore.identityUser, let picture = user.picture {
                    VOAvatar(name: user.fullName, size: 30, base64Image: picture)
                } else {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            if let count = invitationStore.incomingCount, count > 0 {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 14, y: -11)
            }
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        workspaceStore.fetchList(replace: true)
        accountStore.fetchUser()
        invitationStore.fetchIncomingCount()
    }

    private func startTimers() {
        workspaceStore.startTimer()
        accountStore.startTimer()
        invitationStore.startTimer()
    }

    private func stopTimers() {
        workspaceStore.stopTimer()
        accountStore.stopTimer()
        invitationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        workspaceStore.token = token
        accountStore.token = token
        invitationStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if workspaceStore.isLast(id) {
            workspaceStore.fetchList()
        }
    }
}
