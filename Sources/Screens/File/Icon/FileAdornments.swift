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

struct FileAdornments: View {
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity) {
        self.file = file
    }

    public var body: some View {
        HStack(spacing: VOMetrics.spacingXs) {
            if let snapshot = file.snapshot {
                if snapshot.task?.status == .running {
                    FileBadge.processing
                } else if snapshot.task?.status == .waiting {
                    FileBadge.waiting
                } else if snapshot.task?.status == .error {
                    FileBadge.error
                }
            }
            if let isShared = file.isShared, isShared {
                FileBadge.shared
            }
            if let snapshot = file.snapshot, snapshot.capabilities.mosaic {
                FileBadge.mosaic
            }
            if let snapshot = file.snapshot, snapshot.capabilities.entities || snapshot.capabilities.summary {
                FileBadge.insights
            }
        }
    }
}
