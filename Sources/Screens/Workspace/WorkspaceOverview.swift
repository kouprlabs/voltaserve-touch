import SwiftUI
import VoltaserveCore

struct WorkspaceOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    private var workspace: VOWorkspace.Entity

    init(_ workspace: VOWorkspace.Entity, workspaceStore: WorkspaceStore) {
        self.workspace = workspace
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        VStack {
            if let current = workspaceStore.current {
                VStack {
                    VOAvatar(name: workspace.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            FileOverview(current.rootID, workspaceStore: workspaceStore)
                                .navigationTitle(current.name)
                        } label: {
                            Label("Files", systemImage: "folder")
                        }
                        NavigationLink {
                            WorkspaceSettings(workspaceStore: workspaceStore) {
                                dismiss()
                            }
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(workspace.name)
        .onAppear {
            workspaceStore.current = workspace
        }
    }
}
