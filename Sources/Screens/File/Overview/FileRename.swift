import SwiftUI
import VoltaserveCore

struct FileRename: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var fileStore: FileStore
    @State private var isProcessing = false
    @State private var value = ""
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var showError = false
    @State var file: VOFile.Entity?
    private let id: String
    private let onCompletion: (() -> Void)?

    init(_ id: String, onCompletion: (() -> Void)?) {
        self.id = id
        self.onCompletion = onCompletion
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
                                performRename()
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
                    Button("Done") { onCompletion?() }
                        .disabled(isProcessing)
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

    private func fetch() {
        VOErrorResponse.withErrorHandling {
            file = try await fileStore.fetch(id)
        } failure: { message in
            errorTitle = "Error: Renaming File"
            errorMessage = message
            showError = true
        }
    }

    private func performRename() {
        isProcessing = true
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            Task { @MainActor in
                onCompletion?()
                isProcessing = false
            }
        }
    }
}
