import SwiftUI
import VoltaserveCore

struct FileUpload: View {
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorType: ErrorType?
    @State private var errorMessage: String?
    private let urls: [URL]
    private let onCompletion: (() -> Void)?

    init(_ urls: [URL], onCompletion: (() -> Void)? = nil) {
        self.urls = urls
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                ProgressView()
                    .frame(width: Constants.errorIconSize, height: Constants.errorIconSize)
                if urls.count == 1 {
                    Text("Uploading item.")
                } else {
                    Text("Uploading \(urls.count) items.")
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
                Button {
                    onCompletion?()
                } label: {
                    VOButtonLabel("Done")
                }
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
                Button {
                    onCompletion?()
                } label: {
                    VOButtonLabel("Done")
                }
                .voButton(color: colorScheme == .dark ? VOColors.gray700 : VOColors.gray200)
                .padding(.horizontal)
            }
        }
        .onAppear { performUpload() }
        .presentationDetents([.fraction(0.25)])
    }

    private func performUpload() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            if urls.count == 1 {
                onSuccess()
            } else if urls.count == 2 {
                onError(count: 2)
            } else if urls.count == 3 {
                onError(count: 1)
            } else {
                onSuccess()
            }
        }
    }

    private func onSuccess() {
        isProcessing = false
        showError = false
        errorType = .unknown
        onCompletion?()
    }

    private func onError(count: Int) {
        isProcessing = false
        showError = true
        if urls.count == 1 {
            errorType = .all
            errorMessage = "Failed to upload item."
        } else if count == urls.count {
            errorType = .all
            errorMessage = "Failed to upload \(count) item(s)."
        } else if count < urls.count {
            errorType = .some
            errorMessage = "Failed to upload \(count) item(s)."
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
