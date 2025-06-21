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

public struct WorkspaceCreate: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var organization: VOOrganization.Entity?
    @State private var storageCapacity: Int? = 30_000_000_000
    @State private var isProcessing = false
    private let onCompletion: ((VOWorkspace.Entity) -> Void)?

    public init(workspaceStore: WorkspaceStore, onCompletion: ((VOWorkspace.Entity) -> Void)? = nil) {
        self.workspaceStore = workspaceStore
        self.onCompletion = onCompletion
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section(header: VOSectionHeader("Basics")) {
                    TextField("Name", text: $name)
                        .disabled(isProcessing)
                    NavigationLink {
                        OrganizationSelector { organization in
                            self.organization = organization
                        }
                    } label: {
                        HStack {
                            Text("Organization")
                            if let organization {
                                Spacer()
                                Text(organization.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(isProcessing)
                }
                Section(header: VOSectionHeader("Storage Capacity")) {
                    VOStoragePicker(value: $storageCapacity)
                        .disabled(isProcessing)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Workspace")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Create") {
                            performCreate()
                        }
                        .disabled(!isValid())
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func performCreate() {
        guard let organization, let storageCapacity else { return }
        var workspace: VOWorkspace.Entity?

        withErrorHandling {
            workspace = try await workspaceStore.create(
                .init(
                    name: normalizedName,
                    organizationID: organization.id,
                    storageCapacity: storageCapacity
                ))
            if let workspace {
                try await workspaceStore.syncEntities()
            }
            if workspaceStore.isLastPage() {
                workspaceStore.fetchNextPage()
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
        !normalizedName.isEmpty && organization != nil && storageCapacity != nil && storageCapacity! > 0
    }
}
