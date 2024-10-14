import SwiftUI

struct FileSheetDelete: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showDelete = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showDelete) {
                if !fileStore.selection.isEmpty {
                    FileDelete(fileStore: fileStore)
                }
            }
            .sync($fileStore.showDelete, with: $showDelete)
    }
}

extension View {
    func fileSheetDelete(fileStore: FileStore) -> some View {
        modifier(FileSheetDelete(fileStore: fileStore))
    }
}
