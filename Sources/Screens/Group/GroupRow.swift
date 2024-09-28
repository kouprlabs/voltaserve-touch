import SwiftUI
import VoltaserveCore

struct GroupRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let group: VOGroup.Entity

    init(_ group: VOGroup.Entity) {
        self.group = group
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(name: group.name, size: VOMetrics.avatarSize)
            VStack(alignment: .leading) {
                Text(group.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)

                Text(group.organization.name)
                    .font(.footnote)
                    .foregroundStyle(.gray)
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
