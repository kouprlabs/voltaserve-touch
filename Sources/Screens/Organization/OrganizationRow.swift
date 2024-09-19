import SwiftUI
import VoltaserveCore

struct OrganizationRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let organization: VOOrganization.Entity

    init(_ organization: VOOrganization.Entity) {
        self.organization = organization
    }

    var body: some View {
        HStack(spacing: 15) {
            VOAvatar(name: organization.name, size: 45)
            Text(organization.name)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
    }
}
