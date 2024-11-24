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

struct VOFormHintLabel: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(.custom(VOMetrics.bodyFontFamily, size: 15))
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .underline()
    }
}

extension View {
    func voFormHintLabel() -> some View {
        modifier(VOFormHintLabel())
    }
}

#Preview {
    Button {
    } label: {
        Text("Lorem ipsum")
            .voFormHintLabel()
    }
}
