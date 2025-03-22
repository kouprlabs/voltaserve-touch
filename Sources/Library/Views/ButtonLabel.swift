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

public struct VOButtonLabel: View {
    private let text: String?
    private let systemImage: String?
    private let isLoading: Bool
    private let progressViewTint: Color

    public init(
        _ text: String? = nil,
        systemImage: String? = nil,
        isLoading: Bool = false,
        progressViewTint: Color = .primary
    ) {
        self.text = text
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.progressViewTint = progressViewTint
    }

    public var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
            }
            if let text {
                Text(text)
            }
            if isLoading {
                ProgressView()
                    .tint(progressViewTint)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VOButtonLabel("Lorem Ipsum", isLoading: true)
}
