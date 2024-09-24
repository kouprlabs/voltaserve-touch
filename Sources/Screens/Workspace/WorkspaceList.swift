import Combine
import SwiftUI
import VoltaserveCore

struct WorkspaceList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var accountStore: AccountStore
    @EnvironmentObject private var invitationStore: InvitationStore
    @State private var showAccount = false
    @State private var showNewWorkspace = false

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
                                        .navigationBarTitleDisplayMode(.inline)
                                        .navigationTitle(workspace.name)
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
                .searchable(text: $workspaceStore.searchText)
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
                        NavigationLink {
                            WorkspaceNew()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAccount) {
                    AccountOverview()
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $workspaceStore.showError,
            title: workspaceStore.errorTitle,
            message: workspaceStore.errorMessage
        )
        .onAppear {
            workspaceStore.clear()
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            workspaceStore.stopTimer()
            accountStore.stopTimer()
            invitationStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: workspaceStore.query) {
            workspaceStore.clear()
            workspaceStore.fetchList()
        }
    }

    var accountButton: some View {
        ZStack {
            Button {
                showAccount.toggle()
            } label: {
                if let user = accountStore.identityUser, let picture = user.picture {
                    VOAvatar(name: user.fullName, size: 30, base64Image: picture)
                        .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
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
        workspaceStore.fetchList(replace: true)
        fetchUser()
        fetchInvitationIncomingCount()
        workspaceStore.startTimer()
        accountStore.startTimer()
        invitationStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if workspaceStore.isLast(id) {
            workspaceStore.fetchList()
        }
    }

    private func fetchUser() {
        var user: VOIdentityUser.Entity?
        withErrorHandling {
            user = try await accountStore.fetchUser()
            return true
        } success: {
            accountStore.identityUser = user
        } failure: { message in
            workspaceStore.errorTitle = "Error: Fetching User"
            workspaceStore.errorMessage = message
            workspaceStore.showError = true
        }
    }

    private func fetchInvitationIncomingCount() {
        var count: Int?
        withErrorHandling {
            count = try await invitationStore.fetchIncomingCount()
            return true
        } success: {
            invitationStore.incomingCount = count
        } failure: { message in
            workspaceStore.errorTitle = "Error: Fetching Invitation Incoming Count"
            workspaceStore.errorMessage = message
            workspaceStore.showError = true
        }
    }
}
