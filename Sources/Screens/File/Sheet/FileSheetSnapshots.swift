import SwiftUI
import VoltaserveCore

struct FileSheetSnapshots: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showSnapshots = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showSnapshots) {
                if let file {
                    SnapshotList(fileID: file.id)
                }
            }
            .sync($fileStore.showSnapshots, with: $showSnapshots)
    }

    private var file: VOFile.Entity? {
        if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
            return file
        }
        return nil
    }
}

extension View {
    func fileSheetSnapshots(fileStore: FileStore) -> some View {
        modifier(FileSheetSnapshots(fileStore: fileStore))
    }
}
