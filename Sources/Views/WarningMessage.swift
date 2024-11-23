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

struct VOWarningMessage: View {
    let message: String?
    
    init () {
        message = nil
    }
    
    init(message: String?) {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: VOMetrics.spacingXs) {
            VOWarningIcon()
            if let message {
                Text(message)
                    .foregroundStyle(Color.yellow400)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    VStack(spacing: 100) {
        VOWarningMessage()
        VOWarningMessage(message: "Lorem ipsum dolor sit amet")
        VOWarningMessage(message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
    }
    .padding()
}
