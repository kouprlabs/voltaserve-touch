import SwiftUI

struct FileSheetCopy: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var showBrowser = false
    @State private var showCopy = false
    @State private var destinationID: String?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $showBrowser) {
                NavigationStack {
                    if let workspace = workspaceStore.current {
                        BrowserOverview(workspaceStore: workspaceStore, confirmLabelText: "Copy Here") { id in
                            destinationID = id
                            fileStore.showCopy = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
            }
            .sheet(isPresented: $showCopy) {
                if let destinationID, !fileStore.selection.isEmpty {
                    FileCopy(fileStore: fileStore, to: destinationID)
                }
            }
            .sync($fileStore.showBrowserForCopy, with: $showBrowser)
            .sync($fileStore.showCopy, with: $showCopy)
    }
}

extension View {
    func fileSheetCopy(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheetCopy(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
