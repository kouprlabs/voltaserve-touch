import SwiftUI
import VoltaserveCore

struct FileUpload: View {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let urls: [URL]

    init(_ urls: [URL]) {
        self.urls = urls
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                VOSheetProgressView()
                Text("Uploading \(urls.count) item(s).")
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
            performUpload()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performUpload() {
        guard let workspace = workspaceStore.current else { return }

        let dispatchGroup = DispatchGroup()
        var failedCount = 0
        for url in urls {
            dispatchGroup.enter()
            Task {
                do {
                    try await fileStore.upload(url, workspaceID: workspace.id)
                    dispatchGroup.leave()
                } catch {
                    failedCount += 1
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if failedCount == 0 {
                showError = false
                dismiss()
            } else {
                errorMessage = "Failed to upload \(failedCount) item(s)."
                if failedCount == urls.count {
                    errorSeverity = .full
                } else if failedCount < urls.count {
                    errorSeverity = .partial
                }
                showError = true
            }
            isProcessing = false
        }
    }

    private enum ErrorSeverity {
        case full
        case partial
        case unknown
    }
}
