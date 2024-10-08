import SwiftUI

struct FileToolbar: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.editMode) private var editMode

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
                fileStore.showTasks = true
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
                fileStore.showUploadDocumentPicker = true
            } label: {
                Label("Upload Files", systemImage: "icloud.and.arrow.up")
            }
            Button {
                fileStore.showNewFolder = true
            } label: {
                Label("New Folder", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "plus")
        }
    }

    private var fileMenu: some View {
        FileMenu(
            fileStore.selection,
            onSharing: {
                fileStore.showSharing = true
            },
            onUpload: {
                fileStore.showUploadDocumentPicker = true
            },
            onDownload: {
                fileStore.showDownload = true
            },
            onDelete: {
                fileStore.showDelete = true
            },
            onRename: {
                fileStore.showRename = true
            },
            onMove: {
                fileStore.showBrowserForMove = true
            },
            onCopy: {
                fileStore.showBrowserForCopy = true
            }
        )
    }
}

extension View {
    func fileToolbar() -> some View {
        modifier(FileToolbar())
    }
}
