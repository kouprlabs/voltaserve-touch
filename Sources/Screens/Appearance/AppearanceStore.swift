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

public class AppearanceStore: ObservableObject {
    @Published var accentColor: Color {
        didSet {
            saveAccentColor()
        }
    }

    private static let colorKey = "com.voltaserve.accentColor"

    init() {
        accentColor = Self.loadAccentColor() ?? .blue
    }

    private func saveAccentColor() {
        if let archivedString = accentColor.archivedString {
            UserDefaults.standard.set(archivedString, forKey: Self.colorKey)
        }
    }

    private static func loadAccentColor() -> Color? {
        if let archivedString = UserDefaults.standard.string(forKey: colorKey) {
            return Color(archivedString: archivedString)
        }
        return nil
    }
}
