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
                            FileOverview(current.rootID)
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
        }
    }
}

#Preview {
    WorkspaceOverview(VOWorkspace.Entity.devInstance)
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(WorkspaceStore())
}
