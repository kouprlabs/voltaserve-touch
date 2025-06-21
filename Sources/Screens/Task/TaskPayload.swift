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

public struct TaskPayload: View {
    private let task: VOTask.Entity

    public init(_ task: VOTask.Entity) {
        self.task = task
    }

    public var body: some View {
        if let object = task.payload?.object {
            Form {
                Text(object)
            }
            .navigationTitle("Payload")
        }
    }
}
