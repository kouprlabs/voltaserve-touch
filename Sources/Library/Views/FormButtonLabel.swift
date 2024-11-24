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

struct VOFormButtonLabel: View {
    private let text: String
    private let isLoading: Bool

    init(_ text: String, isLoading: Bool = false) {
        self.text = text
        self.isLoading = isLoading
    }

    var body: some View {
        HStack {
            Text(text)
            if isLoading {
                Spacer()
                ProgressView()
            }
        }
    }
}

#Preview {
    Form {
        Button {
        } label: {
            VOFormButtonLabel("Lorem Ipsum", isLoading: true)
        }
        .disabled(true)
    }
}
