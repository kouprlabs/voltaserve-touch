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

public struct WorkspaceEditStorageCapacity: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var value: Int?
    @State private var isProcessing = false

    public init(workspaceStore: WorkspaceStore) {
        self.workspaceStore = workspaceStore
    }

    public var body: some View {
        VStack {
            if let current = workspaceStore.current {
                Form {
                    VOStoragePicker(value: $value)
                        .disabled(isProcessing)
                }
                .onAppear {
                    value = current.storageCapacity
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Change Storage Capacity")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if isProcessing {
                    ProgressView()
                } else {
                    Button("Save") {
                        performSave()
                    }
                    .disabled(!isValid())
                }
            }
        }
        .onChange(of: workspaceStore.current) { _, newCurrent in
            if let newCurrent {
                value = newCurrent.storageCapacity
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performSave() {
        guard let value else { return }
        guard let current = workspaceStore.current else { return }

        withErrorHandling {
            let workspace = try await workspaceStore.patchStorageCapacity(
                current.id,
                options: .init(storageCapacity: value)
            )
            if let workspace {
                try await workspaceStore.syncCurrent(workspace: workspace)
            }
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented = false
    @State public var errorMessage: String?

    // MARK: - FormValidatable

    public func isValid() -> Bool {
        if let value, let current = workspaceStore.current {
            return value > 0 && current.storageCapacity != value
        }
        return false
    }
}
