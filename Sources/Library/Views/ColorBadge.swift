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

struct VOColorBadge: View {
    private let text: String
    private let color: Color
    private let style: Style

    init(_ text: String, color: Color, style: Style) {
        self.text = text
        self.color = color
        self.style = style
    }

    var body: some View {
        if style == .fill {
        } else if style == .outline {
        }
        Text(text)
            .font(.footnote)
            .padding(.horizontal)
            .frame(height: 20)
            .modifierIf(style == .fill) {
                $0
                    .foregroundStyle(color.textColor())
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .modifierIf(style == .outline) {
                $0
                    .foregroundStyle(color)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color, lineWidth: 1)
                    }
            }
    }

    enum Style {
        case fill
        case outline
    }
}

#Preview {
    VStack {
        VOColorBadge("Red", color: .red400, style: .fill)
        VOColorBadge("Purple", color: .purple400, style: .fill)
        VOColorBadge("Green", color: .green400, style: .fill)
        VOColorBadge("Red", color: .red400, style: .outline)
        VOColorBadge("Purple", color: .purple400, style: .outline)
        VOColorBadge("Green", color: .green400, style: .outline)
    }
}
