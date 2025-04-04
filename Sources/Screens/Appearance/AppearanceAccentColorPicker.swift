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

public struct AppearanceAccentColorPicker: View {
    @ObservedObject private var appearanceStore: AppearanceStore

    let colors: [Color] = [.blue, .purple, .pink, .red, .orange, .yellow, .green, .gray]

    public init(appearanceStore: AppearanceStore) {
        self.appearanceStore = appearanceStore
    }

    public var body: some View {
        let columns = [
            GridItem(.adaptive(minimum: AppearanceAccentColorCircle.defaultSize), spacing: VOMetrics.spacing)
        ]
        HStack {
            LazyVGrid(columns: columns, spacing: VOMetrics.spacing) {
                ForEach(colors, id: \.self) { color in
                    AppearanceAccentColorCircle(color)
                        .modifierIf(appearanceStore.accentColor.archivedString == color.archivedString) {
                            $0.overlay(
                                Circle().stroke(Color.primary, lineWidth: 3)
                            )
                        }
                        .onTapGesture {
                            appearanceStore.accentColor = color
                        }
                }
            }
        }
        .padding(VOMetrics.spacingLg)
    }
}

public struct AppearanceAccentColorCircle: View {
    private let color: Color
    private let size: CGFloat
    public static let defaultSize: CGFloat = 36

    public init(_ color: Color, size: CGFloat = defaultSize) {
        self.color = color
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}
