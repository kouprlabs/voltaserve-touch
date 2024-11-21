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

struct FileSheetUpload: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showPicker = false
    @State private var showUpload = false
    @State private var pickerURLs: [URL]?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showPicker) {
                FileUploadPicker { urls in
                    pickerURLs = urls
                    fileStore.showUploadDocumentPicker = false
                    fileStore.showUpload = true
                }
            }
            .sheet(isPresented: $showUpload) {
                if let pickerURLs {
                    FileUpload(pickerURLs, fileStore: fileStore, workspaceStore: workspaceStore)
                }
            }
            .sync($fileStore.showUploadDocumentPicker, with: $showPicker)
            .sync($fileStore.showUpload, with: $showUpload)
    }
}

extension View {
    func fileSheetUpload(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetUpload(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
