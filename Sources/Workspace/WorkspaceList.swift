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

    var body: some View {
        NavigationStack {
            if let list = workspaceStore.list {
                List(list.data, id: \.id) { workspace in
                    NavigationLink {
                        FileList(workspace.rootID, workspace: workspace)
                            .navigationTitle(workspace.name)
                    } label: {
                        WorkspaceRow(workspace)
                    }
                }
                .searchable(text: $searchText)
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
                assignTokenToStores(token)
                fetchData()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                fetchData()
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
            do {
                let list = try await workspaceStore.fetchList()
                Task { @MainActor in
                    workspaceStore.list = list
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
