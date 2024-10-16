import SwiftUI

struct FileDownloadPicker: UIViewControllerRepresentable {
    let urls: [URL]
    let onCompletion: (() -> Void)?

    init(sourceURLs: [URL], onCompletion: (() -> Void)? = nil) {
        urls = sourceURLs
        self.onCompletion = onCompletion
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sourceURLs: urls, onCompletion: onCompletion)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forExporting: urls)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let sourceURLs: [URL]
        let onCompletion: (() -> Void)?

        init(sourceURLs: [URL], onCompletion: (() -> Void)?) {
            self.sourceURLs = sourceURLs
            self.onCompletion = onCompletion
        }

        func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
            onCompletion?()
        }
    }
}
