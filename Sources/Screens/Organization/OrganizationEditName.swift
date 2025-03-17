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

public struct OrganizationEditName: View, FormValidatable, ErrorPresentable {
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isProcessing = false
    private let onCompletion: ((VOOrganization.Entity) -> Void)?

    public init(organizationStore: OrganizationStore, onCompletion: ((VOOrganization.Entity) -> Void)? = nil) {
        self.organizationStore = organizationStore
        self.onCompletion = onCompletion
    }

    public var body: some View {
        VStack {
            if let current = organizationStore.current {
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
        .onChange(of: organizationStore.current) { _, newCurrent in
            if let newCurrent {
                value = newCurrent.name
            }
        }
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private var nornalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        guard let current = organizationStore.current else { return }
        var updatedOrganization: VOOrganization.Entity?

        withErrorHandling {
            updatedOrganization = try await organizationStore.patchName(current.id, name: nornalizedValue)
            return true
        } before: {
            isProcessing = true
        } success: {
            dismiss()
            if let onCompletion, let updatedOrganization {
                onCompletion(updatedOrganization)
            }
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isProcessing = false
        }
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented: Bool = false
    @State public var errorMessage: String?

    // MARK: - FormValidatable

    public func isValid() -> Bool {
        if let current = organizationStore.current {
            return !nornalizedValue.isEmpty && nornalizedValue != current.name
        }
        return false
    }
}
