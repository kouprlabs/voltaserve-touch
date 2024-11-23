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

struct SharingUserRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let userPermission: VOFile.UserPermission
    private let userPictureURL: URL?

    init(_ userPermission: VOFile.UserPermission, userPictureURL: URL? = nil) {
        self.userPermission = userPermission
        self.userPictureURL = userPictureURL
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(
                name: userPermission.user.fullName,
                size: VOMetrics.avatarSize,
                url: userPictureURL
            )
            VStack(alignment: .leading) {
                Text(userPermission.user.fullName)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(userPermission.user.email)
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            VOPermissionBadge(userPermission.permission)
        }
    }
}

#Preview {
    SharingUserRow(.init(
        id: UUID().uuidString,
        user: VOUser.Entity(
            id: UUID().uuidString,
            username: "brucelee@example.com",
            email: "brucelee@example.com",
            fullName: "Bruce Lee",
            createTime: Date().ISO8601Format()
        ),
        permission: .editor
    ))
}
