import SwiftUI
import VoltaserveCore

struct InvitationStatusBadge: View {
    var status: VOInvitation.InvitationStatus

    init(_ status: VOInvitation.InvitationStatus) {
        self.status = status
    }

    var body: some View {
        Text(text())
            .font(.footnote)
            .padding(.horizontal)
            .frame(height: 20)
            .foregroundStyle(background().textColor())
            .background(background())
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    func text() -> String {
        switch status {
        case .pending:
            "Pending"
        case .accepted:
            "Accepted"
        case .declined:
            "Declined"
        }
    }

    func background() -> Color {
        switch status {
        case .pending:
            .gray300
        case .accepted:
            .green300
        case .declined:
            .red300
        }
    }
}

#Preview {
    VStack {
        InvitationStatusBadge(.pending)
        InvitationStatusBadge(.accepted)
        InvitationStatusBadge(.declined)
    }
}
