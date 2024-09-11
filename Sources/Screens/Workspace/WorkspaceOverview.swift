import SwiftUI
import VoltaserveCore

struct WorkspaceOverview: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    private var workspace: VOWorkspace.Entity

    init(_ workspace: VOWorkspace.Entity) {
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            if let current = workspaceStore.current {
                VStack {
                    VOAvatar(name: workspace.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            FileList(current.rootID)
                                .navigationTitle(current.name)
                        } label: {
                            Label("Files", systemImage: "folder")
                        }
                        NavigationLink {
                            WorkspaceSettings {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .navigationTitle("Settings")
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            workspaceStore.current = workspace
            if let token = authStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        workspaceStore.token = token
    }
}

#Preview {
    WorkspaceOverview(VOWorkspace.Entity.devInstance)
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(WorkspaceStore())
}
