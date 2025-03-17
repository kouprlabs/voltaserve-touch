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

public struct VOLogo: View {
    @Environment(\.colorScheme) private var colorScheme
    private let isGlossy: Bool
    private let size: CGSize

    public init(isGlossy: Bool = false, size: CGSize) {
        self.isGlossy = isGlossy
        self.size = size
    }

    public var body: some View {
        if colorScheme == .dark {
            if isGlossy {
                Image("logo-dark-glossy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            } else {
                Image("logo-dark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            }
        } else {
            if isGlossy {
                Image("logo-glossy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            } else {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

#Preview {
    VStack {
        VOLogo(size: .init(width: 100, height: 100))
        VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
    }
}
