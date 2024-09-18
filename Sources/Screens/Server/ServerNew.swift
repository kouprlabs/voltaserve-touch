import SwiftUI

struct ServerNew: View {
    @EnvironmentObject var serverStore: ServerStore
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var apiURL = ""
    @State private var idpURL = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section(header: VOSectionHeader("Properties")) {
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
            Section {
                Button {
                    performSave()
                } label: {
                    HStack {
                        Text("Save")
                        if isSaving {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isSaving || !isValid())
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Server")
                    .font(.headline)
            }
        }
    }

    private func isValid() -> Bool {
        !name.isEmpty && !apiURL.isEmpty && !idpURL.isEmpty
    }

    private func performSave() {
        isSaving = true
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            Task { @MainActor in
                serverStore.create(ServerStore.Entity(
                    id: UUID().uuidString,
                    name: name,
                    apiURL: apiURL,
                    idpURL: idpURL,
                    isCloud: false,
                    isActive: false
                ))
                presentationMode.wrappedValue.dismiss()
                isSaving = false
            }
        }
    }
}

#Preview {
    ServerNew()
}
