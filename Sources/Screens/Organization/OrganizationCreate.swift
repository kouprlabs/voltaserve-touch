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

struct OrganizationCreate: View {
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let onCompletion: ((VOOrganization.Entity) -> Void)?

    init(
        organizationStore: OrganizationStore, onCompletion: ((VOOrganization.Entity) -> Void)? = nil
    ) {
        self.organizationStore = organizationStore
        self.onCompletion = onCompletion
    }

    var body: some View {
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
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        }
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func performCreate() {
        isProcessing = true
        var organization: VOOrganization.Entity?

        withErrorHandling {
            organization = try await organizationStore.create(name: normalizedName)
            return true
        } success: {
            dismiss()
            if let onCompletion, let organization {
                onCompletion(organization)
            }
        } failure: { message in
            errorTitle = "Error: Creating Organization"
            errorMessage = message
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        !normalizedName.isEmpty
    }
}
