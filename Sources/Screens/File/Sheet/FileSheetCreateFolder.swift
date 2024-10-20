import SwiftUI

struct FileSheetCreateFolder: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showCreate = false

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showCreate) {
                if let parent = fileStore.current, let workspace = workspaceStore.current {
                    FolderCreate(parentID: parent.id, workspaceId: workspace.id, fileStore: fileStore)
                }
            }
            .sync($fileStore.showCreateFolder, with: $showCreate)
    }
}

extension View {
    func fileSheetCreateFolder(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetCreateFolder(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
