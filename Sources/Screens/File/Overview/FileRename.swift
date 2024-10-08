import SwiftUI
import VoltaserveCore

struct FileRename: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var value = ""
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var showError = false
    @State var file: VOFile.Entity?

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    var body: some View {
        NavigationView {
            VStack {
                if file != nil {
                    Form {
                        TextField("Name", text: $value)
                            .disabled(isSaving)
                    }

                } else {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Rename")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performRename()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                fetch()
            }
            .onChange(of: file) { _, newFile in
                if let newFile {
                    value = newFile.name
                }
            }
        }
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func fetch() {
        guard let id = fileStore.selection.first else { return }
        withErrorHandling {
            file = try await fileStore.fetch(id)
            return true
        } failure: { message in
            errorTitle = "Error: Fetching File"
            errorMessage = message
            showError = true
        }
    }

    private func performRename() {
        guard let file else { return }
        isSaving = true

        withErrorHandling {
            try await fileStore.patchName(file.id, name: normalizedValue)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Renaming File"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let file {
            return !normalizedValue.isEmpty && normalizedValue != file.name
        }
        return false
    }
}
