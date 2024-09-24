import SwiftUI

struct FileToolbar: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    @Environment(\.editMode) private var editMode

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        content
            .toolbar {
                if fileStore.viewMode == .list {
                    ToolbarItem(placement: .topBarTrailing) {
                        EditButton()
                    }
                    if editMode?.wrappedValue.isEditing == true, fileStore.selection.count > 0 {
                        ToolbarItem(placement: .bottomBar) {
                            FileMenu(
                                fileStore.selection,
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
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        fileStore.toggleViewMode()
                    } label: {
                        Image(systemName: fileStore.viewMode == .list ? "square.grid.2x2" : "list.bullet")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
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
            }
    }
}

extension View {
    func fileToolbar() -> some View {
        modifier(FileToolbar())
    }
}
