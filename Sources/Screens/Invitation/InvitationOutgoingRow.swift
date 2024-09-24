import SwiftUI
import VoltaserveCore

struct InvitationOutgoingRow: View {
    @Environment(\.editMode) private var editMode
    private let invitation: VOInvitation.Entity
    private let onInfo: ((VOInvitation.Entity) -> Void)?
    private let onDeletion: ((VOInvitation.Entity) -> Void)?

    init(
        _ invitation: VOInvitation.Entity,
        onInfo: ((VOInvitation.Entity) -> Void)? = nil,
        onDeletion: ((VOInvitation.Entity) -> Void)? = nil
    ) {
        self.invitation = invitation
        self.onInfo = onInfo
        self.onDeletion = onDeletion
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            if editMode?.wrappedValue == .active {
                Button {
                    onDeletion?(invitation)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .scaleEffect(VOMetrics.sfSymbolScaleEffect)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
            }
            VStack(alignment: .leading) {
                Text(invitation.email)
                Text(invitation.createTime.relativeDate())
                    .foregroundStyle(.secondary)
                    .font(.footnote)
                InvitationStatusBadge(invitation.status)
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

#Preview {
    @Previewable @State var showInfo = false
    @Previewable @State var showDeleteConfirmation = false

    let owner = VOUser.Entity(
        id: UUID().uuidString,
        username: "anass@example.com",
        email: "anass@example.com",
        fullName: "Anass",
        createTime: Date().ISO8601Format()
    )

    NavigationView {
        List {
            InvitationOutgoingRow(
                VOInvitation.Entity(
                    id: UUID().uuidString,
                    owner: owner,
                    email: "bruce@koupr.com",
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
                showInfo = true
            } onDeletion: { _ in
                showDeleteConfirmation = true
            }
            InvitationOutgoingRow(
                VOInvitation.Entity(
                    id: UUID().uuidString,
                    owner: owner,
                    email: "tony@koupr.com",
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
                showInfo = true
            } onDeletion: { _ in
                showDeleteConfirmation = true
            }
            InvitationOutgoingRow(
                VOInvitation.Entity(
                    id: UUID().uuidString,
                    owner: owner,
                    email: "steve@koupr.com",
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
                showInfo = true
            } onDeletion: { _ in
                showDeleteConfirmation = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }
        .popover(isPresented: $showInfo) {
            Text("This is the info about the invitation.")
        }
        .confirmationDialog(
            "Delete Invitation",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {}
        } message: {
            Text("Are you sure you want to delete this invitation?")
        }
    }
}
