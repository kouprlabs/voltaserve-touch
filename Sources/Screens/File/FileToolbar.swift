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

struct FileToolbar: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.editMode) private var editMode

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .toolbar {
                if fileStore.viewMode == .list {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                    if editMode?.wrappedValue.isEditing == true, fileStore.selection.count > 0 {
                        ToolbarItem(placement: .bottomBar) {
                            fileMenu
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    viewModeToggleButton
                }
                ToolbarItem(placement: .topBarTrailing) {
                    tasksButton
                }
                ToolbarItem(placement: .topBarLeading) {
                    uploadMenu
                }
                ToolbarItem(placement: .topBarLeading) {
                    if fileStore.entitiesIsLoading {
                        ProgressView()
                    }
                }
            }
    }

    private var viewModeToggleButton: some View {
        Button {
            fileStore.toggleViewMode()
        } label: {
            Image(systemName: fileStore.viewMode == .list ? "square.grid.2x2" : "list.bullet")
        }
    }

    private var tasksButton: some View {
        ZStack {
            Button {
                fileStore.tasksIsPresented = true
            } label: {
                Image(systemName: "square.3.layers.3d")
            }
            if let taskCount = fileStore.taskCount, taskCount > 0 {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .offset(x: 12, y: -10)
            }
        }
    }

    private var uploadMenu: some View {
        Menu {
            Button {
                fileStore.uploadDocumentPickerIsPresented = true
            } label: {
                Label("Upload Files", systemImage: "icloud.and.arrow.up")
            }
            Button {
                fileStore.createFolderIsPresented = true
            } label: {
                Label("New Folder", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    private var fileMenu: some View {
        FileMenu(
            fileStore: fileStore,
            onSharing: {
                fileStore.sharingIsPresented = true
            },
            onUpload: {
                fileStore.uploadDocumentPickerIsPresented = true
            },
            onDownload: {
                fileStore.downloadIsPresented = true
            },
            onDelete: {
                fileStore.deleteIsPresented = true
            },
            onRename: {
                fileStore.renameIsPresented = true
            },
            onMove: {
                fileStore.browserForMoveIsPresented = true
            },
            onCopy: {
                fileStore.browserForCopyIsPresented = true
            }
        )
    }
}

extension View {
    func fileToolbar(fileStore: FileStore) -> some View {
        modifier(FileToolbar(fileStore: fileStore))
    }
}
