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

struct FileGrid: View, ListItemScrollable {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var tappedItem: VOFile.Entity?
    @State private var viewerIsPresented: Bool = false

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        if let entities = fileStore.entities {
            GeometryReader { geometry in
                let padding = VOMetrics.spacing * 2
                let safeWidth = geometry.size.width - geometry.safeAreaInsets.leading - geometry.safeAreaInsets.trailing
                let additional = UIDevice.current.userInterfaceIdiom == .pad ? -1 : 0
                let columns = Array(
                    repeating: GridItem(.fixed(FileCellMetrics.cellSize.width), spacing: VOMetrics.spacing),
                    count: Int((safeWidth - padding) / FileCellMetrics.cellSize.width) + additional
                )
                ScrollView {
                    LazyVGrid(columns: columns, spacing: VOMetrics.spacing) {
                        ForEach(entities, id: \.id) { file in
                            if file.type == .file {
                                Button {
                                    if !(file.snapshot?.task?.isPending ?? false) {
                                        tappedItem = file
                                        viewerIsPresented = true
                                    }
                                } label: {
                                    FileCell(file, fileStore: fileStore)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            } else if file.type == .folder {
                                NavigationLink {
                                    FileOverview(file, workspaceStore: workspaceStore)
                                        .navigationTitle(file.name)
                                } label: {
                                    FileCell(file, fileStore: fileStore)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $viewerIsPresented) {
                        if let tappedItem {
                            Viewer(tappedItem)
                        }
                    }
                    .modifierIfPhone {
                        $0.padding(.vertical, VOMetrics.spacing)
                    }
                }
            }
            .modifierIfPad {
                $0.edgesIgnoringSafeArea(.bottom)
            }
        }
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if fileStore.isEntityThreshold(id) {
            fileStore.fetchNextPage()
        }
    }
}
