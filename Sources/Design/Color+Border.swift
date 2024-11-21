// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Foundation
import SwiftUI

extension Color {
    static func borderColor(colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            Color(.sRGB, red: 255 / 255, green: 255 / 255, blue: 255 / 255, opacity: 0.16)
        } else {
            Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
        }
    }
}
