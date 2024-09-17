import SwiftUI

struct FileDownloadPicker: UIViewControllerRepresentable {
    let urls: [URL]
    let onDismiss: (() -> Void)?

    init(sourceURLs: [URL], onDismiss: (() -> Void)? = nil) {
        urls = sourceURLs
        self.onDismiss = onDismiss
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(sourceURLs: urls, onDismiss: onDismiss)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forExporting: urls)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let sourceURLs: [URL]
        let onDismiss: (() -> Void)?

        init(sourceURLs: [URL], onDismiss: (() -> Void)?) {
            self.sourceURLs = sourceURLs
            self.onDismiss = onDismiss
        }

        func documentPickerWasCancelled(_: UIDocumentPickerViewController) {
            onDismiss?()
        }
    }
}
