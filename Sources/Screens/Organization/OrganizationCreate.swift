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

public struct OrganizationCreate: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    private let onCompletion: ((VOOrganization.Entity) -> Void)?

    public init(organizationStore: OrganizationStore, onCompletion: ((VOOrganization.Entity) -> Void)? = nil) {
        self.organizationStore = organizationStore
        self.onCompletion = onCompletion
    }

    public var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                    .disabled(isProcessing)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Organization")
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
        var organization: VOOrganization.Entity?
        withErrorHandling {
            organization = try await organizationStore.create(name: normalizedName)
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
            if let onCompletion, let organization {
                onCompletion(organization)
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
        !normalizedName.isEmpty
    }
}
