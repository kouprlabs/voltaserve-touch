import SwiftUI
import VoltaserveCore

struct FileRename: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @State private var isProcessing = false
    @State private var value = ""
    @State private var errorMessage: String?
    @State private var showError = false
    @State var file: VOFile.Entity?
    private let id: String
    private let onDismiss: (() -> Void)?

    init(_ id: String, onDismiss: (() -> Void)?) {
        self.id = id
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationView {
            VStack {
                if file != nil {
                    Form {
                        Section(header: VOSectionHeader("Name")) {
                            TextField("Name", text: $value)
                                .disabled(isProcessing)
                        }
                        Section {
                            Button {
                                isProcessing = true
                                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                                    Task { @MainActor in
                                        onDismiss?()
                                        isProcessing = false
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Save")
                                    if isProcessing {
                                        Spacer()
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(isProcessing)
                        }
                    }

                } else {
                    ProgressView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Rename")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { onDismiss?() }
                        .disabled(isProcessing)
                }
            }
            .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                Button(VOTextConstants.errorAlertButtonLabel) {}
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                if let token = authStore.token {
                    onAppearOrChange(token)
                }
            }
            .onChange(of: authStore.token) { _, newToken in
                if let newToken {
                    onAppearOrChange(newToken)
                }
            }
            .onChange(of: file) { _, newFile in
                if let newFile {
                    value = newFile.name
                }
            }
        }
    }

    private func onAppearOrChange(_ token: VOToken.Value) {
        assignTokenToStores(token)
        fetch()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }

    private func fetch() {
        Task {
            do {
                file = try await fileStore.fetch(id)
            } catch let error as VOErrorResponse {
                Task {
                    errorMessage = error.userMessage
                    showError = true
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }
}
