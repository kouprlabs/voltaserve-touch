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

struct SnapshotFeatures: View {
    private let snapshot: VOSnapshot.Entity

    init(_ snapshot: VOSnapshot.Entity) {
        self.snapshot = snapshot
    }

    var body: some View {
        HStack {
            if snapshot.entities != nil {
                VOColorBadge("Insights", color: .gray400, style: .outline)
            }
            if snapshot.mosaic != nil {
                VOColorBadge("Mosaic", color: .gray400, style: .outline)
            }
        }
    }
}

extension VOSnapshot.Entity {
    func hasFeatures() -> Bool {
        entities != nil || mosaic != nil
    }

    func hasEntities() -> Bool {
        entities != nil
    }

    func hasMosaic() -> Bool {
        mosaic != nil
    }
}
