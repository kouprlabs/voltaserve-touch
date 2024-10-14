import SwiftUI

struct FileSheetUpload: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showPicker = false
    @State private var showUpload = false
    @State private var pickerURLs: [URL]?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showPicker) {
                FileUploadPicker { urls in
                    pickerURLs = urls
                    fileStore.showUploadDocumentPicker = false
                    fileStore.showUpload = true
                }
            }
            .sheet(isPresented: $showUpload) {
                if let pickerURLs {
                    FileUpload(pickerURLs, fileStore: fileStore, workspaceStore: workspaceStore)
                }
            }
            .sync($fileStore.showUploadDocumentPicker, with: $showPicker)
            .sync($fileStore.showUpload, with: $showUpload)
    }
}

extension View {
    func fileSheetUpload(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetUpload(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
