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
import VoltaserveCore

struct FileCellAdornments: ViewModifier {
    var file: VOFile.Entity

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            FileAdornments(file)
                .offset(x: FileCellMetrics.badgeOffset.width, y: FileCellMetrics.badgeOffset.height)
        }
    }
}

extension View {
    func fileCellAdornments(_ file: VOFile.Entity) -> some View {
        modifier(FileCellAdornments(file: file))
    }
}
