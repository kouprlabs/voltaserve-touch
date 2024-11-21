// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

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
