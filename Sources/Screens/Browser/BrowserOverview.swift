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
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?

    public init(
        workspaceStore: WorkspaceStore,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)?
    ) {
        self.workspaceStore = workspaceStore
        self.onCompletion = onCompletion
        self.confirmLabelText = confirmLabelText
    }

    public var body: some View {
        if let workspace = workspaceStore.current {
            NavigationStack {
                BrowserList(
                    workspace.rootID,
                    workspaceStore: workspaceStore,
                    confirmLabelText: confirmLabelText
                ) { id in
                    onCompletion?(id)
                    dismiss()
                } onDismiss: {
                    dismiss()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(workspace.name)
            }
        }
    }
}
