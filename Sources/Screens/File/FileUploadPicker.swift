import SwiftUI
import UniformTypeIdentifiers

struct FileUploadPicker: UIViewControllerRepresentable {
    var onFilesPicked: ([URL]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data])
        documentPicker.delegate = context.coordinator
        documentPicker.allowsMultipleSelection = true
        return documentPicker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FileUploadPicker

        init(parent: FileUploadPicker) {
            self.parent = parent
        }

        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.onFilesPicked(urls)
        }

        func documentPickerWasCancelled(_: UIDocumentPickerViewController) {}
    }
}
