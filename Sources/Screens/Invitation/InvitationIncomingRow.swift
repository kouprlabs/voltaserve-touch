import SwiftUI
import VoltaserveCore

struct InvitationIncomingRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let invitation: VOInvitation.Entity
    private let onAction: ((VOInvitation.Entity) -> Void)?
    private let onInfo: ((VOInvitation.Entity) -> Void)?

    init(
        _ invitation: VOInvitation.Entity,
        onAction: ((VOInvitation.Entity) -> Void)? = nil,
        onInfo: ((VOInvitation.Entity) -> Void)? = nil
    ) {
        self.invitation = invitation
        self.onAction = onAction
        self.onInfo = onInfo
    }

    var body: some View {
        Button {
            onAction?(invitation)
        } label: {
            HStack(spacing: VOMetrics.spacing) {
                if let organization = invitation.organization {
                    VOAvatar(name: organization.name, size: VOMetrics.avatarSize)
                }
                VStack(alignment: .leading) {
                    if let organization = invitation.organization {
                        Text(organization.name)
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                    }
                    Text(invitation.createTime.relativeDate())
                        .foregroundStyle(.gray)
                        .font(.footnote)
                }
                Spacer()
                Button {
                    onInfo?(invitation)
                } label: {
                    Image(systemName: "info.circle")
                        .scaleEffect(VOMetrics.sfSymbolScaleEffect)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var showInfo = false
    @Previewable @State var showAction = false

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
            ) { _ in
                showAction = true
            } onInfo: { _ in
                showInfo = true
            }
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
            ) { _ in
                showAction = true
            } onInfo: { _ in
                showInfo = true
            }
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
            ) { _ in
                showAction = true
            } onInfo: { _ in
                showInfo = true
            }
        }
    }
    .popover(isPresented: $showInfo) {
        Text("This is the info about the invitation.")
    }
    .confirmationDialog(
        "Confirm Invitation",
        isPresented: $showAction,
        titleVisibility: .visible
    ) {
        Button("Accept") {}
        Button("Decline", role: .destructive) {}
    } message: {
        Text("Do you want to accept or decline this invitation?")
    }
}
