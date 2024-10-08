import SwiftUI
import VoltaserveCore

struct FileDelete: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                VOSheetProgressView()
                Text("Deleting \(fileStore.selection.count) item(s).")
            } else if showError, errorSeverity == .full {
                VOSheetErrorIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    dismiss()
                } label: {
                    VOButtonLabel("Done")
                }
                .voSecondaryButton(colorScheme: colorScheme)
                .padding(.horizontal)
            } else if showError, errorSeverity == .partial {
                SheetWarningIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    dismiss()
                } label: {
                    VOButtonLabel("Done")
                }
                .voSecondaryButton(colorScheme: colorScheme)
                .padding(.horizontal)
            }
        }
        .onAppear {
            performDelete()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performDelete() {
        var result: VOFile.DeleteResult?
        withErrorHandling {
            result = try await fileStore.delete(Array(fileStore.selection))
            errorSeverity = .full
            if let result {
                if result.failed.isEmpty {
                    return true
                } else {
                    errorMessage = "Failed to delete \(result.failed.count) item(s)."
                    if result.failed.count < fileStore.selection.count {
                        errorSeverity = .partial
                    }
                    showError = true
                }
            }
            return false
        } success: {
            showError = false
            dismiss()
        } failure: { _ in
            errorMessage = "Failed to delete \(fileStore.selection.count) item(s)."
            errorSeverity = .full
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private enum ErrorSeverity {
        case full
        case partial
    }
}
