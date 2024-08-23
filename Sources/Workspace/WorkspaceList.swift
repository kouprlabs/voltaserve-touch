import SwiftUI

struct WorkspaceList: View {
    var workspaces = [
        "Workspace 1",
        "Workspace 2",
        "Workspace 3"
    ]

    var body: some View {
        NavigationStack {
            List(workspaces, id: \.self) { workspace in
                NavigationLink(workspace) {
                    FileList()
                        .navigationTitle(workspace)
                }
            }
        }
    }
}

#Preview {
    WorkspaceList()
}
