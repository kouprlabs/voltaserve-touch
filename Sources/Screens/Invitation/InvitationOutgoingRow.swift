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

public struct InvitationOutgoingRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let invitation: VOInvitation.Entity
    private let verticalStatus: Bool

    public init(_ invitation: VOInvitation.Entity, verticalStatus: Bool = false) {
        self.invitation = invitation
        self.verticalStatus = verticalStatus
    }

    public var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VStack(alignment: .leading) {
                Text(invitation.email)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(invitation.createTime.relativeDate())
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                if UIDevice.current.userInterfaceIdiom == .phone {
                    InvitationStatusBadge(invitation.status)
                }
                if verticalStatus && UIDevice.current.userInterfaceIdiom == .pad {
                    InvitationStatusBadge(invitation.status)
                }
            }
            if !verticalStatus {
                Spacer()
                if UIDevice.current.userInterfaceIdiom == .pad {
                    InvitationStatusBadge(invitation.status)
                }
            }
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
            )
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
            )
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
            )
        }
    }
}
