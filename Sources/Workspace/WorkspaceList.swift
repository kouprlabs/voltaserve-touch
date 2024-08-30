import SwiftUI

struct WorkspaceList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
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
                        Label("Account", systemImage: "person.crop.circle")
                    }
                }
                .sheet(isPresented: $showAccount) {
                    Account()
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            if let token = authStore.token {
                workspaceStore.token = token
                fetchList()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let token = newToken {
                workspaceStore.token = token
                fetchList()
            }
        }
    }

    func fetchList() {
        Task {
            let list = try await workspaceStore.fetchList()
            Task { @MainActor in
                workspaceStore.list = list
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
