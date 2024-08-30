import SwiftUI
import Voltaserve

struct GroupRow: View {
    private let group: VOGroup.Entity

    init(_ group: VOGroup.Entity) {
        self.group = group
    }

    var body: some View {
        HStack(spacing: 15) {
            VOAvatar(name: group.name, size: 45)
            VStack(alignment: .leading) {
                Text(group.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(group.organization.name)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    GroupRow(.init(
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
    ))
}
