import SwiftUI
import VoltaserveCore

struct SharingGroupRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let groupPermission: VOFile.GroupPermission

    init(_ groupPermission: VOFile.GroupPermission) {
        self.groupPermission = groupPermission
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(name: groupPermission.group.name, size: VOMetrics.avatarSize)
            VStack(alignment: .leading) {
                Text(groupPermission.group.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(groupPermission.group.organization.name)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
            Spacer()
            SharingPermissionBadge(groupPermission.permission)
        }
    }
}

#Preview {
    SharingGroupRow(.init(
        id: UUID().uuidString,
        group: .init(
            id: UUID().uuidString,
            name: "My Group",
            organization: .init(
                id: UUID().uuidString,
                name: "My Organization",
                permission: .owner,
                createTime: Date().ISO8601Format()
            ),
            permission: .owner,
            createTime: Date().ISO8601Format()
        ),
        permission: .owner
    ))
}
