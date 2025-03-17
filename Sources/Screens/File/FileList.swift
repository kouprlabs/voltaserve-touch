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

public struct FileList: View, ListItemScrollable {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var tappedItem: VOFile.Entity?
    @State private var viewerIsPresented: Bool = false

    public init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    public var body: some View {
        if let entities = fileStore.entities {
            List(selection: $fileStore.selection) {
                ForEach(entities, id: \.id) { file in
                    if file.type == .file {
                        Button {
                            if !(file.snapshot?.task?.isPending ?? false) {
                                tappedItem = file
                                viewerIsPresented = true
                            }
                        } label: {
                            FileRow(file)
                                .fileActions(file, fileStore: fileStore)
                        }
                        .onAppear {
                            onListItemAppear(file.id)
                        }
                    } else if file.type == .folder {
                        NavigationLink {
                            FileOverview(file, workspaceStore: workspaceStore)
                                .navigationTitle(file.name)
                        } label: {
                            FileRow(file)
                                .fileActions(file, fileStore: fileStore)
                        }
                        .onAppear {
                            onListItemAppear(file.id)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .fullScreenCover(isPresented: $viewerIsPresented) {
                if let tappedItem {
                    Viewer(tappedItem)
                }
            }
        }
    }

    // MARK: - ListItemScrollable

    public func onListItemAppear(_ id: String) {
        if fileStore.isEntityThreshold(id) {
            fileStore.fetchNextPage()
        }
    }
}
