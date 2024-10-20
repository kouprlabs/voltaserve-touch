import SwiftUI
import VoltaserveCore

struct FileRename: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @Environment(\.dismiss) private var dismiss
    @State private var isSaving = false
    @State private var value = ""
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var showError = false
    private let file: VOFile.Entity
    private let onCompletion: ((VOFile.Entity) -> Void)?

    init(_ file: VOFile.Entity, onCompletion: ((VOFile.Entity) -> Void)? = nil) {
        self.file = file
        self.onCompletion = onCompletion
    }

    var body: some View {
        NavigationView {
            VStack {
                if !value.isEmpty {
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
                fileStore.current = file
                if let token = tokenStore.token {
                    assignTokenToStores(token)
                    startTimers()
                    onAppearOrChange()
                }
            }
            .onDisappear {
                stopTimers()
            }
            .onChange(of: tokenStore.token) { _, newToken in
                if let newToken {
                    assignTokenToStores(newToken)
                    onAppearOrChange()
                }
            }
            .onChange(of: fileStore.current) { _, file in
                if let file {
                    value = file.name
                }
            }
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        fileStore.fetch()
    }

    private func startTimers() {
        fileStore.startTimer()
    }

    private func stopTimers() {
        fileStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performRename() {
        guard let file = fileStore.current else { return }
        isSaving = true
        var updatedFile: VOFile.Entity?

        withErrorHandling {
            updatedFile = try await fileStore.patchName(file.id, name: normalizedValue)
            return true
        } success: {
            dismiss()
            if let onCompletion, let updatedFile {
                onCompletion(updatedFile)
            }
        } failure: { message in
            errorTitle = "Error: Renaming File"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let file = fileStore.current {
            return !normalizedValue.isEmpty && normalizedValue != file.name
        }
        return false
    }
}
