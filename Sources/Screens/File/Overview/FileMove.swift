import SwiftUI
import VoltaserveCore

struct FileMove: View {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var browserStore: BrowserStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let files: [VOFile.Entity]
    private let destinationID: String

    init(_ files: [VOFile.Entity], to destinationID: String) {
        self.files = files
        self.destinationID = destinationID
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                SheetProgressView()
                Text("Moving \(files.count) item(s).")
            } else if showError, errorSeverity == .full {
                SheetErrorIcon()
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
            performMove()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performMove() {
        var result: VOFile.MoveResult?
        VOErrorResponse.withErrorHandling {
            result = try await fileStore.move(files.map(\.id), to: destinationID)
            errorSeverity = .full
            if let result {
                if result.failed.isEmpty {
                    return true
                } else {
                    errorMessage = "Failed to move \(result.failed.count) item(s)."
                    if result.failed.count < files.count {
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
            errorMessage = "Failed to move \(files.count) item(s)."
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
