import SwiftUI
import VoltaserveCore

struct FileSheets: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var documentPickerURLs: [URL]?
    @State private var destinationIDForMove: String?
    @State private var destinationIDForCopy: String?
    @State private var showBrowserForMove = false
    @State private var showBrowserForCopy = false
    @State private var showTasks = false
    @State private var showSharing = false
    @State private var showSnapshots = false
    @State private var showMove = false
    @State private var showCopy = false
    @State private var showRename = false
    @State private var showDelete = false
    @State private var showDownload = false
    @State private var showUpload = false
    @State private var showNewFolder = false
    @State private var showDownloadDocumentPicker = false
    @State private var showUploadDocumentPicker = false

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        if let workspace = workspaceStore.current {
            content
                .sheet(isPresented: $showBrowserForMove) {
                    NavigationStack {
                        BrowserOverview(workspaceStore: workspaceStore, confirmLabelText: "Move Here") { id in
                            destinationIDForMove = id
                            fileStore.showMove = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
                .sheet(isPresented: $showTasks) {
                    TaskList()
                }
                .sheet(isPresented: $showSharing) {
                    if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
                        SharingOverview(file, workspaceStore: workspaceStore)
                    } else if fileStore.selection.count > 1 {
                        SharingBatch(fileStore.selectionFiles, workspaceStore: workspaceStore)
                    }
                }
                .sheet(isPresented: $showSnapshots) {
                    if fileStore.selection.count == 1, let file = fileStore.selectionFiles.first {
                        SnapshotList(file: file)
                    }
                }
                .sheet(isPresented: $showMove) {
                    if let destinationIDForMove, !fileStore.selection.isEmpty {
                        FileMove(fileStore: fileStore, to: destinationIDForMove)
                    }
                }
                .sheet(isPresented: $showBrowserForCopy) {
                    NavigationStack {
                        BrowserOverview(workspaceStore: workspaceStore, confirmLabelText: "Copy Here") { id in
                            destinationIDForCopy = id
                            fileStore.showCopy = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
                .sheet(isPresented: $showCopy) {
                    if let destinationIDForCopy, !fileStore.selection.isEmpty {
                        FileCopy(fileStore: fileStore, to: destinationIDForCopy)
                    }
                }
                .sheet(isPresented: $showRename) {
                    if !fileStore.selection.isEmpty {
                        FileRename(fileStore: fileStore)
                    }
                }
                .sheet(isPresented: $showDelete) {
                    if !fileStore.selection.isEmpty {
                        FileDelete(fileStore: fileStore)
                    }
                }
                .sheet(isPresented: $showDownload) {
                    if !fileStore.selection.isEmpty {
                        FileDownload(fileStore: fileStore) { localURLs in
                            documentPickerURLs = localURLs
                            fileStore.showDownloadDocumentPicker = true
                        }
                    }
                }
                .sheet(isPresented: $showDownloadDocumentPicker, onDismiss: handleDismissDownloadPicker) {
                    if let documentPickerURLs {
                        FileDownloadPicker(
                            sourceURLs: documentPickerURLs,
                            onCompletion: handleDismissDownloadPicker
                        )
                    }
                }
                .sheet(isPresented: $showUploadDocumentPicker) {
                    FileUploadPicker { urls in
                        documentPickerURLs = urls
                        fileStore.showUploadDocumentPicker = false
                        fileStore.showUpload = true
                    }
                }
                .sheet(isPresented: $showUpload) {
                    if let documentPickerURLs {
                        FileUpload(documentPickerURLs, fileStore: fileStore, workspaceStore: workspaceStore)
                    }
                }
                .sheet(isPresented: $showNewFolder) {
                    if let parent = fileStore.current, let workspace = workspaceStore.current {
                        FolderCreate(parentID: parent.id, workspaceId: workspace.id, fileStore: fileStore)
                    }
                }
                .sync($fileStore.showBrowserForMove, with: $showBrowserForMove)
                .sync($fileStore.showBrowserForCopy, with: $showBrowserForCopy)
                .sync($fileStore.showTasks, with: $showTasks)
                .sync($fileStore.showSharing, with: $showSharing)
                .sync($fileStore.showSnapshots, with: $showSnapshots)
                .sync($fileStore.showMove, with: $showMove)
                .sync($fileStore.showCopy, with: $showCopy)
                .sync($fileStore.showRename, with: $showRename)
                .sync($fileStore.showDelete, with: $showDelete)
                .sync($fileStore.showDownload, with: $showDownload)
                .sync($fileStore.showUpload, with: $showUpload)
                .sync($fileStore.showNewFolder, with: $showNewFolder)
                .sync($fileStore.showDownloadDocumentPicker, with: $showDownloadDocumentPicker)
                .sync($fileStore.showUploadDocumentPicker, with: $showUploadDocumentPicker)
        }
    }

    private func handleDismissDownloadPicker() {
        if let documentPickerURLs {
            let fileManager = FileManager.default
            for url in documentPickerURLs where fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        fileStore.showDownloadDocumentPicker = false
    }
}

extension View {
    func fileSheets(fileStore: FileStore, workspaceStore: WorkspaceStore) -> some View {
        modifier(FileSheets(fileStore: fileStore, workspaceStore: workspaceStore))
    }
}
