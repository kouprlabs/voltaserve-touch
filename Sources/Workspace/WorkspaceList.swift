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

    var body: some View {
        NavigationStack {
            if let list = workspaceStore.list {
                List(list.data, id: \.id) { workspace in
                    NavigationLink {
                        FileList(workspace.rootID)
                            .navigationTitle(workspace.name)
                    } label: {
                        WorkspaceRow(workspace)
                    }
                }
                .navigationTitle("Home")
                .toolbar {
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
                    .padding(.trailing, VOMetrics.spacingXs)
                }
                .sheet(isPresented: $showAccount) {
                    Account()
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert("Workspace List Error", isPresented: $showError) {
            Button("Cancel") {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            if let token = authStore.token {
                workspaceStore.token = token
                accountStore.token = token
                fetchList()
                fetchUser()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                workspaceStore.token = newToken
                accountStore.token = newToken
            }
        }
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
                    errorMessage = VOMessages.unexpectedError
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
                    errorMessage = VOMessages.unexpectedError
                }
            }
        }
    }
}

#Preview {
    WorkspaceList()
        .environmentObject(AuthStore())
        .environmentObject(WorkspaceStore())
        .environmentObject(AccountStore())
}
