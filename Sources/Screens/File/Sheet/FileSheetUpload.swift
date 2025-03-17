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

public struct FileSheetUpload: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var pickerURLs: [URL]?

    public init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    public func body(content: Content) -> some View {
        content
            .sheet(isPresented: $fileStore.uploadDocumentPickerIsPresented) {
                FileUploadPicker { urls in
                    pickerURLs = urls
                    fileStore.uploadDocumentPickerIsPresented = false
                    fileStore.uploadIsPresented = true
                }
            }
            .sheet(isPresented: $fileStore.uploadIsPresented) {
                if let pickerURLs {
                    FileUpload(pickerURLs, fileStore: fileStore, workspaceStore: workspaceStore)
                }
            }
    }
}

extension View {
    public func fileSheetUpload(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetUpload(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
