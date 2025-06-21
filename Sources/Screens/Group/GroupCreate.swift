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

public struct GroupCreate: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    @State private var organization: VOOrganization.Entity?
    private var onCompletion: ((VOGroup.Entity?) -> Void)?

    public init(groupStore: GroupStore, onCompletion: ((VOGroup.Entity?) -> Void)? = nil) {
        self.groupStore = groupStore
        self.onCompletion = onCompletion
    }

    public var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .disabled(isProcessing)
                NavigationLink {
                    OrganizationSelector { organization in
                        self.organization = organization
                    }
                    .disabled(isProcessing)
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Group")
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
        guard let organization else { return }
        var group: VOGroup.Entity?

        withErrorHandling {
            group = try await groupStore.create(
                .init(
                    name: normalizedName,
                    organizationID: organization.id
                )
            )
            if let group {
                try await groupStore.syncEntities()
            }
            if groupStore.isLastPage() {
                groupStore.fetchNextPage()
            }
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
            if let onCompletion, let group {
                onCompletion(group)
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
        !normalizedName.isEmpty && organization != nil
    }
}
