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

public struct FileActions: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity, fileStore: FileStore) {
        self.file = file
        self.fileStore = fileStore
    }

    public func body(content: Content) -> some View {
        content
            .fileContextMenu(
                file,
                fileStore: fileStore,
                onInsights: {
                    fileStore.insightsIsPresented = true
                },
                onMosaic: {
                    fileStore.mosaicIsPresented = true
                },
                onSharing: {
                    fileStore.sharingIsPresented = true
                },
                onSnapshots: {
                    fileStore.snapshotsIsPresented = true
                },
                onUpload: {
                    fileStore.uploadDocumentPickerIsPresented = true
                },
                onDownload: {
                    fileStore.downloadIsPresented = true
                },
                onDelete: {
                    fileStore.deleteConfirmationIsPresented = true
                },
                onRename: {
                    fileStore.renameIsPresented = true
                },
                onMove: {
                    fileStore.browserForMoveIsPresented = true
                },
                onCopy: {
                    fileStore.browserForCopyIsPresented = true
                },
                onOpen: {
                    if let snapshot = file.snapshot,
                        let fileExtension = snapshot.original.fileExtension,
                        let url = fileStore.urlForOriginal(file.id, fileExtension: String(fileExtension.dropFirst()))
                    {
                        UIApplication.shared.open(url)
                    }
                },
                onInfo: {
                    fileStore.infoIsPresented = true
                }
            )
    }
}

extension View {
    public func fileActions(_ file: VOFile.Entity, fileStore: FileStore) -> some View {
        modifier(FileActions(file, fileStore: fileStore))
    }
}
