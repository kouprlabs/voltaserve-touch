import SwiftUI
import VoltaserveCore

struct FileCopy: View {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var browserStore: BrowserStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let files: [VOFile.Entity]
    private let onCompletion: (() -> Void)?

    init(_ files: [VOFile.Entity], onCompletion: (() -> Void)? = nil) {
        self.files = files
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                SheetProgressView()
                Text("Copying \(files.count) item(s).")
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
            performCopy()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performCopy() {
        guard let destination = browserStore.current else { return }
        var result: VOFile.CopyResult?
        VOErrorResponse.withErrorHandling {
            result = try await fileStore.copy(files.map(\.id), to: destination.id)
            errorSeverity = .full
            if let result {
                if result.failed.isEmpty {
                    return true
                } else {
                    errorMessage = "Failed to copy \(result.failed.count) item(s)."
                    if result.failed.count < files.count {
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
            errorMessage = "Failed to copy \(files.count) item(s)."
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
