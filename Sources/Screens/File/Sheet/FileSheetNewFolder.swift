import SwiftUI

struct FileSheetNewFolder: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showNewFolder = false

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showNewFolder) {
                if let parent = fileStore.current, let workspace = workspaceStore.current {
                    FolderCreate(parentID: parent.id, workspaceId: workspace.id, fileStore: fileStore)
                }
            }
            .sync($fileStore.showNewFolder, with: $showNewFolder)
    }
}

extension View {
    func fileSheetNewFolder(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetNewFolder(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
