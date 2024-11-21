// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

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
