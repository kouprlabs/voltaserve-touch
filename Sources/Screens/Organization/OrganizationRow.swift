import SwiftUI
import VoltaserveCore

struct OrganizationRow: View {
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
        }
    }
}

#Preview {
    OrganizationRow(VOOrganization.Entity.devInstance)
}
