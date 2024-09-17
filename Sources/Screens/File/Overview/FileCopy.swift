import SwiftUI
import VoltaserveCore

struct FileCopy: View {
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.colorScheme) private var colorScheme
    private let files: [VOFile.Entity]
    private let onDismiss: (() -> Void)?
    @State private var isProcessing = true
    @State private var showError = false
    @State private var errorType: ErrorType?
    @State private var errorMessage: String?

    init(_ files: [VOFile.Entity], onDismiss: (() -> Void)? = nil) {
        self.files = files
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack {
            if isProcessing, !showError {
                ProgressView()
                    .frame(width: Constants.errorIconSize, height: Constants.errorIconSize)
                if files.count == 1 {
                    Text("Copying item.")
                } else {
                    Text("Copying \(files.count) items.")
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
                Button { onDismiss?() } label: { VOButtonLabel("Done") }
                    .voButton(color: colorScheme == .dark ? VOColors.gray700 : VOColors.gray200)
                    .padding(.horizontal)
            }
        }
        .onAppear { performCopy() }
        .presentationDetents([.fraction(0.25)])
    }

    func performCopy() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            if files.count == 1 {
                onSuccess()
            } else if files.count == 2 {
                onError(count: 2)
            } else if files.count == 3 {
                onError(count: 1)
            } else {
                onSuccess()
            }
        }
    }

    func onSuccess() {
        isProcessing = false
        showError = false
        errorType = .unknown
        onDismiss?()
    }

    func onError(count: Int) {
        isProcessing = false
        showError = true
        if files.count == 1 {
            errorType = .all
            errorMessage = "Failed to copy item."
        } else if count == files.count {
            errorType = .all
            errorMessage = "Failed to copy \(count) item(s)."
        } else if count < files.count {
            errorType = .some
            errorMessage = "Failed to copy \(count) item(s)."
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
