import SwiftUI
import VoltaserveCore

struct FileDownload: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var urls: [URL] = []
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorSeverity: ErrorSeverity?
    @State private var errorMessage: String?
    private let onCompletion: (([URL]) -> Void)?

    init(fileStore: FileStore, onCompletion: (([URL]) -> Void)? = nil) {
        self.fileStore = fileStore
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                VOSheetProgressView()
                Text("Downloading \(fileStore.selectionFiles.count) item(s).")
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
                    onCompletion?(urls)
                    dismiss()
                } label: {
                    VOButtonLabel("Continue")
                }
                .voPrimaryButton()
                .padding(.horizontal)
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
            performDownload()
        }
        .presentationDetents([.fraction(0.25)])
    }

    private func performDownload() {
        let dispatchGroup = DispatchGroup()
        urls.removeAll()
        for file in fileStore.selectionFiles {
            if let snapshot = file.snapshot,
               let fileExtension = snapshot.original.fileExtension,
               let url = fileStore.urlForOriginal(file.id, fileExtension: String(fileExtension.dropFirst())) {
                dispatchGroup.enter()
                URLSession.shared.downloadTask(with: url) { localURL, _, error in
                    if let localURL, error == nil {
                        let fileManager = FileManager.default
                        let directoryURL = try? fileManager.url(
                            for: .itemReplacementDirectory,
                            in: .userDomainMask,
                            appropriateFor: localURL,
                            create: true
                        )
                        if let directoryURL {
                            let newLocalURL = directoryURL.appendingPathComponent(file.name)
                            do {
                                try fileManager.moveItem(at: localURL, to: newLocalURL)
                                urls.append(newLocalURL)
                            } catch {}
                        }
                    }
                    dispatchGroup.leave()
                }.resume()
            }
        }
        dispatchGroup.notify(queue: .main) {
            if urls.count == fileStore.selection.count {
                showError = false
                isProcessing = false
                onCompletion?(urls)
                dismiss()
            } else {
                let count = fileStore.selection.count - urls.count
                errorMessage = "Failed to download \(count) item(s)."
                if count < fileStore.selection.count {
                    errorSeverity = .partial
                } else {
                    errorSeverity = .full
                }
                showError = true
                isProcessing = false
            }
        }
    }

    private enum ErrorSeverity {
        case full
        case partial
    }
}
