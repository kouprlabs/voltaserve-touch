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

struct FileSheetCopy: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var destinationID: String?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $fileStore.browserForCopyIsPresented) {
                NavigationStack {
                    if let workspace = workspaceStore.current {
                        BrowserOverview(
                            workspaceStore: workspaceStore, confirmLabelText: "Copy Here"
                        ) { id in
                            destinationID = id
                            fileStore.copyIsPresented = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
            }
            .sheet(isPresented: $fileStore.copyIsPresented) {
                if let destinationID, !fileStore.selection.isEmpty {
                    FileCopy(fileStore: fileStore, to: destinationID)
                }
            }
    }
}

extension View {
    func fileSheetCopy(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetCopy(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
