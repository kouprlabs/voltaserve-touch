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
import UIKit
import VoltaserveCore

struct UserRow: View {
    @StateObject private var userStore = UserStore()
    @Environment(\.colorScheme) private var colorScheme
    private let user: VOUser.Entity
    private let pictureURL: URL?

    init(_ user: VOUser.Entity, pictureURL: URL? = nil) {
        self.user = user
        self.pictureURL = pictureURL
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(
                name: user.fullName,
                size: VOMetrics.avatarSize,
                url: pictureURL
            )
            VStack(alignment: .leading) {
                Text(user.fullName)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(user.email)
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}

#Preview {
    UserRow(VOUser.Entity(
        id: UUID().uuidString,
        username: "brucelee@example.com",
        email: "brucelee@example.com",
        fullName: "Bruce Lee",
        createTime: Date().ISO8601Format()
    ))
}
