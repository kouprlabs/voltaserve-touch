import SwiftUI
import Voltaserve

struct WorkspaceList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var accountStore: AccountStore
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var showAccount = false
    @State private var selection: String?
    @State private var searchText = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            if let entities = workspaceStore.entities {
                List {
                    ForEach(entities, id: \.id) { workspace in
                        NavigationLink {
                            FileList(workspace.rootID, workspace: workspace)
                                .navigationTitle(workspace.name)
                        } label: {
                            WorkspaceRow(workspace)
                                .onAppear { onListItemAppear(workspace.id) }
                        }
                    }
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .searchable(text: $searchText)
                .refreshable {
                    workspaceStore.clear()
                    fetchList()
                }
                .navigationTitle("Home")
                .toolbar {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        accountButton
                            .padding(.trailing, VOMetrics.spacingXs)
                    } else {
                        accountButton
                    }
                }
                .sheet(isPresented: $showAccount) {
                    Account()
                }
            } else {
                ProgressView()
            }
        }
        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            if let token = authStore.token {
                onAppearOrChange(token)
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                onAppearOrChange(newToken)
            }
        }
    }

    var accountButton: some View {
        Button {
            showAccount.toggle()
        } label: {
            if let user = accountStore.user, let picture = user.picture {
                VOAvatar(name: user.fullName, size: 30, base64Image: picture)
                    .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
            } else {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
    }

    func onAppearOrChange(_ token: VOToken.Value) {
        assignTokenToStores(token)
        workspaceStore.clear()
        fetchData()
    }

    func onListItemAppear(_ id: String) {
        if workspaceStore.isLast(id) {
            fetchList()
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        workspaceStore.token = token
        accountStore.token = token
    }

    func fetchData() {
        fetchList()
        fetchUser()
    }

    func fetchList() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !workspaceStore.hasNextPage() { return }
                let list = try await workspaceStore.fetchList(page: workspaceStore.nextPage())
                Task { @MainActor in
                    workspaceStore.list = list
                    if let list {
                        workspaceStore.append(list.data)
                    }
                }
            } catch let error as VOErrorResponse {
                showError = true
                errorMessage = error.message
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }

    func fetchUser() {
        Task {
            do {
                let user = try await accountStore.fetchUser()
                Task { @MainActor in
                    accountStore.user = user
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.userMessage
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    WorkspaceList()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(WorkspaceStore())
        .environmentObject(AccountStore())
}
