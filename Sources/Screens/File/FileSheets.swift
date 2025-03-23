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

public struct FileSheets: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore

    public init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    public func body(content: Content) -> some View {
        content
            .fileSheetMove(fileStore: fileStore)
            .fileSheetCopy(fileStore: fileStore)
            .fileSheetDownload(fileStore: fileStore)
            .fileSheetUpload(fileStore: fileStore, workspaceStore: workspaceStore)
            .fileSheetSharing(fileStore: fileStore)
            .fileSheetCreateFolder(fileStore: fileStore, workspaceStore: workspaceStore)
            .fileSheetMosaic(fileStore: fileStore)
            .fileSheetInsights(fileStore: fileStore)
            .fileSheetRename(fileStore: fileStore)
            .fileSheetSnapshots(fileStore: fileStore)
            .fileSheetDelete(fileStore: fileStore)
            .fileSheetTasks(fileStore: fileStore)
            .fileSheetInfo(fileStore: fileStore)
    }
}

extension View {
    public func fileSheets(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheets(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
