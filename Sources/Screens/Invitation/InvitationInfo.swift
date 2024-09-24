import SwiftUI
import VoltaserveCore

struct InvitationInfo: View {
    private let invitation: VOInvitation.Entity

    init(_ invitation: VOInvitation.Entity) {
        self.invitation = invitation
    }

    var body: some View {
        Form {
            if let owner = invitation.owner {
                Section(header: VOSectionHeader("Sender")) {
                    UserRow(owner)
                    HStack {
                        Text("When")
                        Spacer()
                        if let date = invitation.createTime.date {
                            Text(date.pretty)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section(header: VOSectionHeader("Receiver")) {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(invitation.email)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Status")
                    Spacer()
                    InvitationStatusBadge(invitation.status)
                }
            }

            if let organization = invitation.organization {
                Section(header: VOSectionHeader("Organization")) {
                    OrganizationRow(organization)
                }
            }
        }
    }
}

#Preview {
    InvitationInfo(
        VOInvitation.Entity(
            id: UUID().uuidString,
            owner: VOUser.Entity(
                id: UUID().uuidString,
                username: "anass@example.com",
                email: "anass@example.com",
                fullName: "Anass",
                createTime: Date().ISO8601Format()
            ),
            email: "anass@koupr.com",
            organization: VOOrganization.Entity(
                id: UUID().uuidString,
                name: "Koupr",
                permission: .none,
                createTime: Date().ISO8601Format()
            ),
            status: .pending,
            createTime: "2024-09-23T10:00:00Z"
        )
    )
}
