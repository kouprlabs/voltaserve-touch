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

struct FileSheetMove: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showBrowser = false
    @State private var showMove = false
    @State private var destinationID: String?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showBrowser) {
                if let workspace = workspaceStore.current {
                    NavigationStack {
                        BrowserOverview(workspaceStore: workspaceStore, confirmLabelText: "Move Here") { id in
                            destinationID = id
                            fileStore.showMove = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
            }
            .sheet(isPresented: $showMove) {
                if let destinationID, !fileStore.selection.isEmpty {
                    FileMove(fileStore: fileStore, to: destinationID)
                }
            }
            .sync($fileStore.showBrowserForMove, with: $showBrowser)
            .sync($fileStore.showMove, with: $showMove)
    }
}

extension View {
    func fileSheetMove(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetMove(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
