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

struct VOButton: ViewModifier {
    var width: CGFloat?
    var isDisabled: Bool
    var color: Color

    init(
        color: Color = .blue500,
        width: CGFloat? = nil,
        isDisabled: Bool = false
    ) {
        self.color = color
        self.width = width
        self.isDisabled = isDisabled
    }

    func body(content: Content) -> some View {
        if let width {
            content
                .frame(width: width, height: VOButtonMetrics.height)
                .modifier(VOButtonCommons(self))
        } else {
            content
                .frame(height: VOButtonMetrics.height)
                .frame(maxWidth: .infinity)
                .modifier(VOButtonCommons(self))
        }
    }
}

struct VOButtonCommons: ViewModifier {
    var button: VOButton

    init(_ button: VOButton) {
        self.button = button
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .foregroundColor(button.color.textColor())
            .background(button.color)
            .clipShape(RoundedRectangle(cornerRadius: VOButtonMetrics.height / 2))
            .opacity(button.isDisabled ? 0.5 : 1)
            .disabled(button.isDisabled)
    }
}

enum VOButtonMetrics {
    static let height: CGFloat = 40
}

extension View {
    func voButton(
        color: Color,
        width: CGFloat? = nil,
        isDisabled: Bool = false
    ) -> some View {
        modifier(VOButton(color: color, width: width, isDisabled: isDisabled))
    }

    func voPrimaryButton(width: CGFloat? = nil, isDisabled: Bool = false) -> some View {
        modifier(VOButton(color: .blue500, width: width, isDisabled: isDisabled))
    }

    func voSecondaryButton(colorScheme: ColorScheme, width: CGFloat? = nil, isDisabled: Bool = false) -> some View {
        modifier(
            VOButton(
                color: colorScheme == .dark ? .gray700 : .gray200,
                width: width,
                isDisabled: isDisabled
            ))
    }
}

#Preview {
    @Previewable @Environment(\.colorScheme) var colorScheme

    VStack {
        Button {
        } label: {
            VOButtonLabel("Lorem Ipsum")
        }
        .voPrimaryButton(width: 60)
        Button {
        } label: {
            VOButtonLabel("Lorem Ipsum", isLoading: true)
        }
        .voSecondaryButton(colorScheme: colorScheme, width: 200)
        Button {
        } label: {
            VOButtonLabel("Dolor Sit Amet")
        }
        .voButton(color: .red300)
        .padding(.horizontal)
    }
}
