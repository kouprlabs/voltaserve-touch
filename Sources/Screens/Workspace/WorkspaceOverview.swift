import SwiftUI
import VoltaserveCore

struct WorkspaceOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
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
                                dismiss()
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
