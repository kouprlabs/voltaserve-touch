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

struct WorkspaceSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var onCompletion: (() -> Void)?

    init(workspaceStore: WorkspaceStore, onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        Group {
            if let current = workspaceStore.current {
                Form {
                    Section(header: VOSectionHeader("Storage")) {
                        VStack(alignment: .leading) {
                            if let storageUsage = workspaceStore.storageUsage {
                                // swiftlint:disable:next line_length
                                Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                                ProgressView(value: Double(storageUsage.percentage) / 100.0)
                            } else {
                                Text("Calculating…")
                                ProgressView()
                            }
                        }
                        NavigationLink(destination: WorkspaceEditStorageCapacity(workspaceStore: workspaceStore)) {
                            HStack {
                                Text("Capacity")
                                Spacer()
                                Text("\(current.storageCapacity.prettyBytes())")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Basics")) {
                        NavigationLink {
                            WorkspaceEditName(workspaceStore: workspaceStore) { updatedWorkspace in
                                workspaceStore.current = updatedWorkspace
                                if let index = workspaceStore.entities?.firstIndex(where: {
                                    $0.id == updatedWorkspace.id
                                }) {
                                    workspaceStore.entities?[index] = updatedWorkspace
                                }
                            }
                        } label: {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(current.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Advanced")) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
                        } label: {
                            HStack {
                                Text("Delete Workspace")
                                if isDeleting {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isDeleting)
                        .confirmationDialog("Delete Workspace", isPresented: $showDeleteConfirmation) {
                            Button("Delete Permanently", role: .destructive) {
                                performDelete()
                            }
                        } message: {
                            Text("Are you sure you want to delete this workspace?")
                        }
                    }
                }
                .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
                .onAppear {
                    if tokenStore.token != nil {
                        onAppearOnChange()
                    }
                }
                .onChange(of: tokenStore.token) { _, newToken in
                    if newToken != nil {
                        onAppearOnChange()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Settings")
    }

    private func onAppearOnChange() {
        fetchData()
    }

    private func fetchData() {
        workspaceStore.fetchStorageUsage()
    }

    private func performDelete() {
        isDeleting = true
        let current = workspaceStore.current

        withErrorHandling {
            try await workspaceStore.delete()
            return true
        } success: {
            dismiss()
            if let current {
                reflectDeleteInStore(current.id)
            }
            onCompletion?()
        } failure: { message in
            errorTitle = "Error: Deleting Workspace"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }

    private func reflectDeleteInStore(_ id: String) {
        workspaceStore.entities?.removeAll(where: { $0.id == id })
    }
}
