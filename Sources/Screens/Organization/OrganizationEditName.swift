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

struct OrganizationEditName: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isSaving = false
    private let onCompletion: ((VOOrganization.Entity) -> Void)?

    init(organizationStore: OrganizationStore, onCompletion: ((VOOrganization.Entity) -> Void)? = nil) {
        self.organizationStore = organizationStore
        self.onCompletion = onCompletion
    }

    var body: some View {
        if let current = organizationStore.current {
            Form {
                TextField("Name", text: $value)
                    .disabled(isSaving)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Change Name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performSave()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
            .onAppear {
                value = current.name
            }
            .onChange(of: organizationStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.name
                }
            }
        }
    }

    private var nornalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        guard let current = organizationStore.current else { return }
        isSaving = true
        var updatedOrganization: VOOrganization.Entity?

        withErrorHandling {
            updatedOrganization = try await organizationStore.patchName(current.id, name: nornalizedValue)
            return true
        } success: {
            dismiss()
            if let onCompletion, let updatedOrganization {
                onCompletion(updatedOrganization)
            }
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isSaving = false
        }
    }

    // MARK: - ErrorPresentable

    @State var errorIsPresented: Bool = false
    @State var errorMessage: String?

    // MARK: - FormValidatable

    func isValid() -> Bool {
        if let current = organizationStore.current {
            return !nornalizedValue.isEmpty && nornalizedValue != current.name
        }
        return false
    }
}
