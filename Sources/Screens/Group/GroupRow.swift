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

public struct GroupRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let group: VOGroup.Entity

    public init(_ group: VOGroup.Entity) {
        self.group = group
    }

    public var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(name: group.name, size: VOMetrics.avatarSize)
            VStack(alignment: .leading) {
                Text(group.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(group.organization.name)
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
    }
}

#Preview {
    GroupRow(
        .init(
            id: UUID().uuidString,
            name: "My Group",
            organization: .init(
                id: UUID().uuidString,
                name: "My Organization",
                permission: .owner,
                createTime: Date().ISO8601Format()
            ),
            permission: .owner,
            createTime: Date().ISO8601Format()
        ))
}
