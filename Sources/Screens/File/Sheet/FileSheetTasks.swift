import SwiftUI

struct FileSheetTasks: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @State private var showTasks = false

    init(fileStore: FileStore) {
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showTasks) {
                TaskList()
            }
            .sync($fileStore.showTasks, with: $showTasks)
    }
}

extension View {
    func fileSheetTasks(fileStore: FileStore) -> some View {
        modifier(FileSheetTasks(fileStore: fileStore))
    }
}
