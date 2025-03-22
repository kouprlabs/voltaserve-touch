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

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255

        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
    }

    var archivedString: String? {
        guard
            let data = try? NSKeyedArchiver.archivedData(
                withRootObject: UIColor(self),
                requiringSecureCoding: false)
        else { return nil }
        return data.base64EncodedString()
    }

    init?(archivedString: String) {
        guard let data = Data(base64Encoded: archivedString),
            let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? UIColor
        else { return nil }

        self.init(uiColor)
    }
}
