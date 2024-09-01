import SwiftUI
import Voltaserve

struct WorkspaceSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore

    var body: some View {
        if let workspace = workspaceStore.current {
            Text(workspace.name)
        }
    }
}

#Preview {
    WorkspaceSettings()
        .environmentObject(AuthStore())
        .environmentObject(WorkspaceStore())
}
