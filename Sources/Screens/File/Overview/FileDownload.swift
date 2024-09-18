import SwiftUI
import VoltaserveCore

struct FileDownload: View {
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.colorScheme) private var colorScheme
    private let files: [VOFile.Entity]
    private let onCompletion: (([URL]) -> Void)?
    private let onDismiss: (() -> Void)?
    @State private var localURLs: [URL] = []
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorType: ErrorType?
    @State private var errorMessage: String?

    init(
        _ files: [VOFile.Entity],
        _ onCompletion: (([URL]) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.files = files
        self.onCompletion = onCompletion
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                ProgressView()
                    .frame(width: Constants.errorIconSize, height: Constants.errorIconSize)
                if files.count == 1 {
                    Text("Downloading item.")
                } else {
                    Text("Downloading \(files.count) items.")
                }
            } else if showError, errorType == .all {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.errorIconSize, height: Constants.errorIconSize)
                    .foregroundStyle(VOColors.red500)
                if let errorMessage {
                    Text(errorMessage)
                }
                Button { onDismiss?() } label: { VOButtonLabel("Done") }
                    .voButton(color: colorScheme == .dark ? VOColors.gray700 : VOColors.gray200)
                    .padding(.horizontal)
            } else if showError, errorType == .some {
                Image(systemName: "exclamationmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.errorIconSize, height: Constants.errorIconSize)
                    .foregroundStyle(VOColors.yellow300)
                if let errorMessage {
                    Text(errorMessage)
                }
                Button { onCompletion?(localURLs) } label: { VOButtonLabel("Continue") }
                    .voButton()
                    .padding(.horizontal)
                Button { onDismiss?() } label: { VOButtonLabel("Done") }
                    .voButton(color: colorScheme == .dark ? VOColors.gray700 : VOColors.gray200)
                    .padding(.horizontal)
            }
        }
        .onAppear { performDownload() }
        .presentationDetents([.fraction(0.25)])
    }

    private func performDownload() {
        let dispatchGroup = DispatchGroup()
        localURLs.removeAll()
        for file in files {
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
                                localURLs.append(newLocalURL)
                            } catch {}
                        }
                    }
                    dispatchGroup.leave()
                }.resume()
            }
        }
        dispatchGroup.notify(queue: .main) {
            if localURLs.count == files.count {
                onSuccess()
            } else {
                onError(count: files.count - localURLs.count)
            }
        }
    }

    func onSuccess() {
        isProcessing = false
        showError = false
        errorType = .unknown
        onCompletion?(localURLs)
    }

    func onError(count: Int) {
        isProcessing = false
        showError = true
        if files.count == 1 {
            errorType = .all
            errorMessage = "Failed to download item."
        } else if count == files.count {
            errorType = .all
            errorMessage = "Failed to download \(count) item(s)."
        } else if count < files.count {
            errorType = .some
            errorMessage = "Failed to download \(count) item(s)."
        }
    }

    enum ErrorType {
        case all
        case some
        case unknown
    }

    private enum Constants {
        static let errorIconSize: CGFloat = 30
    }
}
