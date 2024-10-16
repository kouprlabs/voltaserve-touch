import SwiftUI
import VoltaserveCore

struct FileSheetInfo: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showInfo = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showInfo) {
                if let file {
                    FileInfo(file)
                }
            }
            .sync($fileStore.showInfo, with: $showInfo)
    }

    private var file: VOFile.Entity? {
        if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
            return file
        }
        return nil
    }
}

extension View {
    func fileSheetInfo(fileStore: FileStore) -> some View {
        modifier(FileSheetInfo(fileStore: fileStore))
    }
}
