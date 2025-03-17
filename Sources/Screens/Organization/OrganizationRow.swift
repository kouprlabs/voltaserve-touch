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

public struct OrganizationRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let organization: VOOrganization.Entity

    public init(_ organization: VOOrganization.Entity) {
        self.organization = organization
    }

    public var body: some View {
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
    OrganizationRow(
        .init(
            id: UUID().uuidString,
            name: "My Organization",
            permission: .owner,
            createTime: Date().ISO8601Format()
        ))
}
