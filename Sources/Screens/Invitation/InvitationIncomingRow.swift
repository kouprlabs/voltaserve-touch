import SwiftUI
import VoltaserveCore

struct InvitationIncomingRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let invitation: VOInvitation.Entity

    init(_ invitation: VOInvitation.Entity) {
        self.invitation = invitation
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let owner = invitation.owner {
                Text(owner.email)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Text(invitation.createTime.relativeDate())
                .font(.footnote)
                .foregroundStyle(Color.gray500)
        }
    }
}

#Preview {
    let owner = VOUser.Entity(
        id: UUID().uuidString,
        username: "anass@example.com",
        email: "anass@example.com",
        fullName: "Anass",
        createTime: Date().ISO8601Format()
    )
    Form {
        List {
            InvitationIncomingRow(
                VOInvitation.Entity(
                    id: UUID().uuidString,
                    owner: owner,
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
            InvitationIncomingRow(
                VOInvitation.Entity(
                    id: UUID().uuidString,
                    owner: owner,
                    email: "anass@koupr.com",
                    organization: VOOrganization.Entity(
                        id: UUID().uuidString,
                        name: "Apple",
                        permission: .none,
                        createTime: Date().ISO8601Format()
                    ),
                    status: .accepted,
                    createTime: "2024-09-22T19:53:41Z"
                )
            )
            InvitationIncomingRow(
                VOInvitation.Entity(
                    id: UUID().uuidString,
                    owner: owner,
                    email: "anass@koupr.com",
                    organization: VOOrganization.Entity(
                        id: UUID().uuidString,
                        name: "Qualcomm",
                        permission: .none,
                        createTime: Date().ISO8601Format()
                    ),
                    status: .declined,
                    createTime: "2024-08-22T19:53:41Z"
                )
            )
        }
    }
}
