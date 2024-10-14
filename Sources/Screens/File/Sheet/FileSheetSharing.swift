import SwiftUI
import VoltaserveCore

struct FileSheetSharing: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showSharing = false

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSharing) {
                if let file {
                    SharingOverview(file, workspaceStore: workspaceStore)
                } else if fileStore.selection.count > 1 {
                    SharingBatch(fileStore.selectionFiles, workspaceStore: workspaceStore)
                }
            }
            .sync($fileStore.showSharing, with: $showSharing)
    }

    private var file: VOFile.Entity? {
        if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
            return file
        }
        return nil
    }
}

extension View {
    func fileSheetSharing(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetSharing(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
