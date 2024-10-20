import SwiftUI

struct FileSheetRename: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showRename = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showRename) {
                if !fileStore.selection.isEmpty, let file = fileStore.selectionFiles.first {
                    FileRename(file) { updatedFile in
                        if let index = fileStore.entities?.firstIndex(where: { $0.id == file.id }) {
                            fileStore.entities?[index] = updatedFile
                        }
                    }
                }
            }
            .sync($fileStore.showRename, with: $showRename)
    }
}

extension View {
    func fileSheetRename(fileStore: FileStore) -> some View {
        modifier(FileSheetRename(fileStore: fileStore))
    }
}
