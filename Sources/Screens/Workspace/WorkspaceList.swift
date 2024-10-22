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
    @State private var showCreate = false
    @State private var showOverview = false
    @State private var showWorkspaceError = false
    @State private var showAccountError = false
    @State private var showInvitationError = false
    @State private var showTaskError = false
    @State private var searchText = ""
    @State private var newWorkspace: VOWorkspace.Entity?

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
                                    WorkspaceOverview(workspace, workspaceStore: workspaceStore)
                                } label: {
                                    WorkspaceRow(workspace)
                                        .onAppear {
                                            onListItemAppear(workspace.id)
                                        }
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .onChange(of: workspaceStore.searchText) {
                            workspaceStore.searchPublisher.send($1)
                        }
                    }
                }
                .navigationTitle("Home")
                .refreshable {
                    workspaceStore.fetchNext(replace: true)
                }
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
                            showCreate = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if workspaceStore.isLoading, workspaceStore.entities != nil {
                            ProgressView()
                        }
                    }
                }
                .sheet(isPresented: $showCreate) {
                    WorkspaceCreate(workspaceStore: workspaceStore) { newWorkspace in
                        self.newWorkspace = newWorkspace
                        showOverview = true
                    }
                }
                .sheet(isPresented: $showAccount) {
                    AccountOverview()
                }
                .navigationDestination(isPresented: $showOverview) {
                    if let newWorkspace {
                        WorkspaceOverview(newWorkspace, workspaceStore: workspaceStore)
                    }
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
            workspaceStore.fetchNext()
        }
        .sync($workspaceStore.searchText, with: $searchText)
        .sync($workspaceStore.showError, with: $showWorkspaceError)
        .sync($accountStore.showError, with: $showAccountError)
        .sync($invitationStore.showError, with: $showInvitationError)
    }

    var accountButton: some View {
        ZStack {
            Button {
                showAccount.toggle()
            } label: {
                if let user = accountStore.identityUser {
                    VOAvatar(
                        name: user.fullName,
                        size: 30,
                        url: accountStore.urlForUserPicture(
                            user.id,
                            fileExtension: user.picture?.fileExtension
                        )
                    )
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
        workspaceStore.fetchNext(replace: true)
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
        if workspaceStore.isEntityThreshold(id) {
            workspaceStore.fetchNext()
        }
    }
}
