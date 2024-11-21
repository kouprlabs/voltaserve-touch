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

struct PermissionBadge: View {
    var permission: VOPermission.Value

    init(_ permission: VOPermission.Value) {
        self.permission = permission
    }

    var body: some View {
        ColorBadge(text(), color: Constants.background, style: .fill)
    }

    func text() -> String {
        switch permission {
        case .viewer:
            "Viewer"
        case .editor:
            "Editor"
        case .owner:
            "Owner"
        case .none:
            "None"
        }
    }

    private enum Constants {
        static let background = Color.gray300
    }
}

#Preview {
    VStack {
        PermissionBadge(.viewer)
        PermissionBadge(.editor)
        PermissionBadge(.owner)
    }
}
