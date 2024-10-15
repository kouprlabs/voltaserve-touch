import SwiftUI
import VoltaserveCore

struct FileSheetMosaic: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showMosaic = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showMosaic) {
                if let file, let snapshot = file.snapshot {
                    if snapshot.hasMosaic() {
                        MosaicSettings(file)
                    } else {
                        MosaicCreate(file.id)
                    }
                }
            }
            .sync($fileStore.showMosaic, with: $showMosaic)
    }

    private var file: VOFile.Entity? {
        if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
            return file
        }
        return nil
    }
}

extension View {
    func fileSheetMosaic(fileStore: FileStore) -> some View {
        modifier(FileSheetMosaic(fileStore: fileStore))
    }
}
