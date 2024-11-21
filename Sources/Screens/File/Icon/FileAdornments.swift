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

struct FileAdornments: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingXs) {
            if let snapshot = file.snapshot {
                if snapshot.status == .processing {
                    FileBadge.processing
                } else if snapshot.status == .waiting {
                    FileBadge.waiting
                } else if snapshot.status == .error {
                    FileBadge.error
                }
            }
            if let isShared = file.isShared, isShared {
                FileBadge.shared
            }
            if file.snapshot?.mosaic != nil {
                FileBadge.mosaic
            }
            if file.snapshot?.entities != nil {
                FileBadge.insights
            }
        }
    }
}
