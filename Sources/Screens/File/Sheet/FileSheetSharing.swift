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
                if let fileID {
                    SharingOverview(fileID, workspaceStore: workspaceStore)
                } else if fileStore.selection.count > 1 {
                    SharingBatch(Array(fileStore.selection), workspaceStore: workspaceStore)
                }
            }
            .sync($fileStore.showSharing, with: $showSharing)
    }

    private var fileID: String? {
        if fileStore.selection.count == 1, let fileID = fileStore.selection.first {
            return fileID
        }
        return nil
    }
}

extension View {
    func fileSheetSharing(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetSharing(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
