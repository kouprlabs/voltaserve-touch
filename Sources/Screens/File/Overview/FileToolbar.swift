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
                        Label("View Mode", systemImage: fileStore.viewMode == .list ? "square.grid.2x2" : "list.bullet")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            fileStore.showUploadDocumentPicker = true
                        } label: {
                            Label("Upload files", systemImage: "icloud.and.arrow.up")
                        }
                        Button {} label: {
                            Label("New folder", systemImage: "folder.badge.plus")
                        }
                    } label: {
                        Label("Upload", systemImage: "plus")
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
