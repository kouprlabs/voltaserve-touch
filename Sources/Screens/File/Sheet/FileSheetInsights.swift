import SwiftUI
import VoltaserveCore

struct FileSheetInsights: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showInsights = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showInsights) {
                if let file {
                    if let snapshot = file.snapshot, snapshot.hasEntities() {
                        InsightsOverview(file)
                    } else {
                        InsightsCreate(file.id)
                    }
                }
            }
            .sync($fileStore.showInsights, with: $showInsights)
    }

    private var file: VOFile.Entity? {
        if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
            return file
        }
        return nil
    }
}

extension View {
    func fileSheetInsights(fileStore: FileStore) -> some View {
        modifier(FileSheetInsights(fileStore: fileStore))
    }
}
