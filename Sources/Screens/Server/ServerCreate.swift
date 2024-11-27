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

struct ServerCreate: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var apiURL = ""
    @State private var idpURL = ""
    @State private var isProcessing = false

    var body: some View {
        Form {
            Section(header: VOSectionHeader("Name")) {
                TextField("Name", text: $name)
                    .disabled(isProcessing)
            }
            Section(header: VOSectionHeader("API URL")) {
                TextField("API URL", text: $apiURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isProcessing)
            }
            Section(header: VOSectionHeader("Identity Provider URL")) {
                TextField("Identity Provider URL", text: $idpURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isProcessing)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New Server")
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
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        isProcessing = true
        Task {
            context.insert(
                Server(
                    id: UUID().uuidString,
                    name: normalizedName,
                    apiURL: apiURL,
                    idpURL: idpURL,
                    isCloud: false,
                    isActive: false
                ))
            try? context.save()
            DispatchQueue.main.async {
                dismiss()
                isProcessing = false
            }
        }
    }

    private func isValid() -> Bool {
        !normalizedName.isEmpty && !apiURL.isEmpty && !idpURL.isEmpty
    }
}
