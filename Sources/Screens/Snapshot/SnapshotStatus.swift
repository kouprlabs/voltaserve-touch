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

struct SnapshotStatus: View {
    private let status: VOSnapshot.Status

    init(_ status: VOSnapshot.Status) {
        self.status = status
    }

    var body: some View {
        Text(text())
    }

    private func text() -> String {
        switch status {
        case .waiting:
            "Waiting"
        case .processing:
            "Processing"
        case .ready:
            "Ready"
        case .error:
            "Error"
        }
    }
}

#Preview {
    SnapshotStatus(.waiting)
    SnapshotStatus(.processing)
    SnapshotStatus(.ready)
    SnapshotStatus(.error)
}
