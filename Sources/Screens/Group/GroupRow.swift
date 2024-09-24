import SwiftUI
import VoltaserveCore

struct GroupRow: View {
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
                Text(group.organization.name)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
