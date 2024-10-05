import SwiftUI
import VoltaserveCore

struct FileSheets: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @State private var documentPickerURLs: [URL]?
    @State private var destinationIDForMove: String?
    @State private var destinationIDForCopy: String?
    @State private var showBrowserForMove = false
    @State private var showBrowserForCopy = false
    @State private var showTasks = false
    @State private var showSharing = false
    @State private var showMove = false
    @State private var showCopy = false
    @State private var showRename = false
    @State private var showDelete = false
    @State private var showDownload = false
    @State private var showUpload = false
    @State private var showNewFolder = false
    @State private var showDownloadDocumentPicker = false
    @State private var showUploadDocumentPicker = false

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        if let workspace = workspaceStore.current {
            content
                .sheet(isPresented: $showBrowserForMove) {
                    NavigationStack {
                        BrowserOverview(
                            workspace.rootID,
                            workspace: workspace,
                            confirmLabelText: "Move Here"
                        ) { id in
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
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        if files.count == 1 {
                            SharingOverview(files.first!)
                        } else if files.count > 1 {
                            SharingBatch(files)
                        }
                    }
                }
                .sheet(isPresented: $showMove) {
                    let files = selectionToFiles()
                    if let destinationIDForMove, !files.isEmpty {
                        FileMove(files, to: destinationIDForMove)
                    }
                }
                .sheet(isPresented: $showBrowserForCopy) {
                    NavigationStack {
                        BrowserOverview(
                            workspace.rootID,
                            workspace: workspace,
                            confirmLabelText: "Copy Here"
                        ) { id in
                            destinationIDForCopy = id
                            fileStore.showCopy = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
                .sheet(isPresented: $showCopy) {
                    let files = selectionToFiles()
                    if let destinationIDForCopy, !files.isEmpty {
                        FileCopy(files, to: destinationIDForCopy)
                    }
                }
                .sheet(isPresented: $showRename) {
                    if !fileStore.selection.isEmpty {
                        FileRename(fileStore.selection.first!)
                    }
                }
                .sheet(isPresented: $showDelete) {
                    if !fileStore.selection.isEmpty {
                        FileDelete(Array(fileStore.selection))
                    }
                }
                .sheet(isPresented: $showDownload) {
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        FileDownload(files) { localURLs in
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
                        FileUpload(documentPickerURLs)
                    }
                }
                .sheet(isPresented: $showNewFolder) {
                    if let parent = fileStore.file, let workspace = workspaceStore.current {
                        FolderNew(parentID: parent.id, workspaceId: workspace.id)
                    }
                }
                .sync($fileStore.showBrowserForMove, with: $showBrowserForMove)
                .sync($fileStore.showBrowserForCopy, with: $showBrowserForCopy)
                .sync($fileStore.showTasks, with: $showTasks)
                .sync($fileStore.showSharing, with: $showSharing)
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

    private func selectionToFiles() -> [VOFile.Entity] {
        var files: [VOFile.Entity] = []
        for id in fileStore.selection {
            let file = fileStore.entities?.first(where: { $0.id == id })
            if let file {
                files.append(file)
            }
        }
        return files
    }
}

extension View {
    func fileSheets() -> some View {
        modifier(FileSheets())
    }
}
