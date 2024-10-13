import SwiftUI

struct ServerCreate: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var apiURL = ""
    @State private var idpURL = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section(header: VOSectionHeader("Name")) {
                TextField("Name", text: $name)
                    .disabled(isSaving)
            }
            Section(header: VOSectionHeader("API URL")) {
                TextField("API URL", text: $apiURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isSaving)
            }
            Section(header: VOSectionHeader("Identity Provider URL")) {
                TextField("Identity Provider URL", text: $idpURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isSaving)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("New Server")
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
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        isSaving = true
        Task {
            context.insert(Server(
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
                isSaving = false
            }
        }
    }

    private func isValid() -> Bool {
        !normalizedName.isEmpty && !apiURL.isEmpty && !idpURL.isEmpty
    }
}
