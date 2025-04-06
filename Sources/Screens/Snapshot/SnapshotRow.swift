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

public struct SnapshotRow: View {
    private let snapshot: VOSnapshot.Entity

    public init(_ snapshot: VOSnapshot.Entity) {
        self.snapshot = snapshot
    }

    public var body: some View {
        HStack(spacing: VOMetrics.spacingSm) {
            VStack(alignment: .leading, spacing: VOMetrics.spacingXs) {
                Text(snapshot.createTime.relativeDate())
                LazyHStack {
                    if snapshot.isActive {
                        VOColorBadge("Active", color: .green, style: .outline)
                    }
                    VOColorBadge("Version \(snapshot.version)", color: .gray400, style: .outline)
                    VOColorBadge(snapshot.original.size.prettyBytes(), color: .gray400, style: .outline)
                }
            }
        }
    }
}
