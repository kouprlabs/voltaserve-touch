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

struct VONumberBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    private let value: Int

    init(_ value: Int) {
        self.value = value
    }

    var body: some View {
        Text("\(value)")
            .padding(value > 9 ? VOMetrics.spacingSm : 0)
            .font(.footnote)
            .fontWeight(.semibold)
            .frame(height: 24)
            .frame(minWidth: 24)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .background(colorScheme == .dark ? .white : .black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    VStack {
        VONumberBadge(1)
        VONumberBadge(10)
        VONumberBadge(100)
        VONumberBadge(1000)
    }
}
