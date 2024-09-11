import SwiftUI
import VoltaserveCore

struct WorkspaceRow: View {
    var workspace: VOWorkspace.Entity

    init(_ workspace: VOWorkspace.Entity) {
        self.workspace = workspace
    }

    var body: some View {
        HStack(spacing: 15) {
            VOAvatar(name: workspace.name, size: 45)
            VStack(alignment: .leading) {
                Text(workspace.name)
                Text(workspace.organization.name)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WorkspaceRow(.init(
        id: UUID().uuidString,
        name: "My Workspace",
        permission: .owner,
        storageCapacity: 100_000_000,
        rootID: UUID().uuidString,
        organization: .init(
            id: UUID().uuidString,
            name: "My Organization",
            permission: .owner,
            createTime: Date().description
        ),
        createTime: Date().description
    ))
}
