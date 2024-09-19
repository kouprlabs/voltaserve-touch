import Combine
import SwiftUI
import VoltaserveCore

struct WorkspaceList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var accountStore: AccountStore
    @State private var showAccount = false

    var body: some View {
        NavigationStack {
            if let entities = workspaceStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
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
                        Button {} label: {
                            Label("New Workspace", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAccount) {
                    AccountSettings()
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
        Button {
            showAccount.toggle()
        } label: {
            if let user = accountStore.identityUser, let picture = user.picture {
                VOAvatar(name: user.fullName, size: 30, base64Image: picture)
                    .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
            } else {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
    }

    private func onAppearOrChange() {
        workspaceStore.fetchList(replace: true)
        fetchUser()
        workspaceStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if workspaceStore.isLast(id) {
            workspaceStore.fetchList()
        }
    }

    private func fetchUser() {
        var user: VOIdentityUser.Entity?

        VOErrorResponse.withErrorHandling {
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
}
