import SwiftUI
import VoltaserveCore

struct OrganizationRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let organization: VOOrganization.Entity

    init(_ organization: VOOrganization.Entity) {
        self.organization = organization
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(name: organization.name, size: VOMetrics.avatarSize)
            Text(organization.name)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
    }
}

#Preview {
    OrganizationRow(VOOrganization.Entity(
        id: UUID().uuidString,
        name: "My Organization",
        permission: .owner,
        createTime: Date().ISO8601Format()
    ))
}
