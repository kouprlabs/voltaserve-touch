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

public struct WorkspaceEditName: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isProcessing = false
    private let onCompletion: ((VOWorkspace.Entity) -> Void)?

    public init(workspaceStore: WorkspaceStore, onCompletion: ((VOWorkspace.Entity) -> Void)? = nil) {
        self.workspaceStore = workspaceStore
        self.onCompletion = onCompletion
    }

    public var body: some View {
        VStack {
            if let current = workspaceStore.current {
                Form {
                    TextField("Name", text: $value)
                        .disabled(isProcessing)
                }
                .onAppear {
                    value = current.name
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Change Name")
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
                value = newCurrent.name
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        guard let current = workspaceStore.current else { return }
        var workspace: VOWorkspace.Entity?

        withErrorHandling {
            workspace = try await workspaceStore.patchName(current.id, name: normalizedValue)
            if let workspace {
                try await self.workspaceStore.syncCurrent(workspace: workspace)
            }
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
            if let onCompletion, let workspace {
                onCompletion(workspace)
            }
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
        if let current = workspaceStore.current,
            !normalizedValue.isEmpty,
            normalizedValue != current.name
        {
            return true
        }
        return false
    }
}
