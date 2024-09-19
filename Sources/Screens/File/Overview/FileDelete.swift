import SwiftUI
import VoltaserveCore

struct FileDelete: View {
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let ids: [String]
    private let onCompletion: (() -> Void)?

    init(_ ids: [String], onCompletion: (() -> Void)? = nil) {
        self.ids = ids
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                SheetProgressView()
                Text("Deleting \(ids.count) item(s).")
            } else if showError, errorSeverity == .full {
                SheetErrorIcon()
                if let errorMessage {
                    Text(errorMessage)
                }
                Button {
                    onCompletion?()
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
                    onCompletion?()
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
        VOErrorResponse.withErrorHandling {
            result = try await fileStore.delete(ids)
            errorSeverity = .full
            if let result {
                if result.failed.isEmpty {
                    return true
                } else {
                    errorMessage = "Failed to delete \(result.failed.count) item(s)."
                    if result.failed.count < ids.count {
                        errorSeverity = .partial
                    }
                    showError = true
                }
            }
            return false
        } success: {
            showError = false
            onCompletion?()
        } failure: { _ in
            errorMessage = "Failed to delete \(ids.count) item(s)."
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
