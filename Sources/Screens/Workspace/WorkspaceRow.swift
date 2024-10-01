import SwiftUI
import VoltaserveCore

struct WorkspaceRow: View {
    @Environment(\.colorScheme) private var colorScheme
    var workspace: VOWorkspace.Entity

    init(_ workspace: VOWorkspace.Entity) {
        self.workspace = workspace
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(name: workspace.name, size: VOMetrics.avatarSize)
            VStack(alignment: .leading) {
                Text(workspace.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(workspace.organization.name)
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)
                    .truncationMode(.tail)
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
