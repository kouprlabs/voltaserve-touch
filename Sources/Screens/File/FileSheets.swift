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
import VoltaserveCore

struct FileSheets: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .fileSheetMove(fileStore: fileStore, workspaceStore: workspaceStore)
            .fileSheetCopy(fileStore: fileStore, workspaceStore: workspaceStore)
            .fileSheetDownload(fileStore: fileStore)
            .fileSheetUpload(fileStore: fileStore, workspaceStore: workspaceStore)
            .fileSheetSharing(fileStore: fileStore, workspaceStore: workspaceStore)
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
    func fileSheets(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheets(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
