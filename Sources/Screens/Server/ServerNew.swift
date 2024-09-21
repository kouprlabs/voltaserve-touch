import SwiftUI

struct ServerNew: View {
    @EnvironmentObject var serverStore: ServerStore
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var apiURL = ""
    @State private var idpURL = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            TextField("Name", text: $name)
                .disabled(isSaving)
            TextField("API URL", text: $apiURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(isSaving)
            TextField("Identity Provider URL", text: $idpURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .disabled(isSaving)
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
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            Task { @MainActor in
                serverStore.create(ServerStore.Entity(
                    id: UUID().uuidString,
                    name: normalizedName,
                    apiURL: apiURL,
                    idpURL: idpURL,
                    isCloud: false,
                    isActive: false
                ))
                dismiss()
                isSaving = false
            }
        }
    }

    private func isValid() -> Bool {
        !normalizedName.isEmpty && !apiURL.isEmpty && !idpURL.isEmpty
    }
}
