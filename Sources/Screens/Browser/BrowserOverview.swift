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

public struct BrowserOverview: View {
    @Environment(\.dismiss) private var dismiss
    private let folder: VOFile.Entity
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?

    public init(
        folder: VOFile.Entity,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)?
    ) {
        self.folder = folder
        self.onCompletion = onCompletion
        self.confirmLabelText = confirmLabelText
    }

    public var body: some View {
        NavigationStack {
            BrowserList(
                folder.workspace.rootID,
                workspace: folder.workspace,
                confirmLabelText: confirmLabelText
            ) { id in
                onCompletion?(id)
                dismiss()
            } onDismiss: {
                dismiss()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(folder.workspace.name)
        }
    }
}
