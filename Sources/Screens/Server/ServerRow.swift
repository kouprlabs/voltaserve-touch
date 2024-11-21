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

struct ServerRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let server: Server

    init(_ server: Server) {
        self.server = server
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingSm) {
            if server.isActive {
                checkmark
            }
            if !server.isActive {
                spacer
            }
            if server.isCloud {
                cloudBadge
            }
            Text(server.name)
                .foregroundStyle(colorScheme == .dark ? .white : .black)
        }
    }

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundStyle(.blue)
            .fontWeight(.medium)
            .frame(width: 20, height: 20)
    }

    private var spacer: some View {
        Color.clear
            .frame(width: 20, height: 20)
    }

    private var cloudBadge: some View {
        Image("social")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: VOMetrics.borderRadiusXs))
            .overlay {
                RoundedRectangle(cornerRadius: VOMetrics.borderRadiusXs)
                    .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
            }
            .frame(width: 20, height: 20)
    }
}
