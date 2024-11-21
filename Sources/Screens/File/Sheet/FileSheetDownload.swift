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

struct FileSheetDownload: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showPicker = false
    @State private var showDownload = false
    @State private var pickerURLs: [URL]?

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showDownload) {
                if !fileStore.selection.isEmpty {
                    FileDownload(fileStore: fileStore) { localURLs in
                        pickerURLs = localURLs
                        fileStore.showDownloadDocumentPicker = true
                    }
                }
            }
            .sheet(isPresented: $showPicker, onDismiss: handleDismiss) {
                if let pickerURLs {
                    FileDownloadPicker(
                        sourceURLs: pickerURLs,
                        onCompletion: handleDismiss
                    )
                }
            }
            .sync($fileStore.showDownloadDocumentPicker, with: $showPicker)
            .sync($fileStore.showDownload, with: $showDownload)
    }

    private func handleDismiss() {
        if let pickerURLs {
            let fileManager = FileManager.default
            for url in pickerURLs where fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        fileStore.showDownloadDocumentPicker = false
    }
}

extension View {
    func fileSheetDownload(fileStore: FileStore) -> some View {
        modifier(FileSheetDownload(fileStore: fileStore))
    }
}
