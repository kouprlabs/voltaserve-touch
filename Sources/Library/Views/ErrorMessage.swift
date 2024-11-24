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

struct VOErrorMessage: View {
    private let message: String?

    init() {
        message = nil
    }

    init(_ message: String?) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: VOMetrics.spacingXs) {
            VOErrorIcon()
            if let message {
                Text(message)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    VStack(spacing: VOMetrics.spacing2Xl) {
        VOErrorMessage("Lorem ipsum dolor sit amet.")
        // swiftlint:disable:next line_length
        VOErrorMessage(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        )
    }
    .padding()
}
