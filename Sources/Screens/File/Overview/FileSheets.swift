import SwiftUI
import VoltaserveCore

struct FileSheets: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @State private var documentPickerURLs: [URL]?
    @State private var destinationIDForMove: String?
    @State private var destinationIDForCopy: String?

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        if let workspace = workspaceStore.current {
            content
                .sheet(isPresented: $fileStore.showBrowserForMove) {
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
                .sheet(isPresented: $fileStore.showSharing) {
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        if files.count == 1 {
                            SharingOverview(files.first!)
                        } else if files.count > 1 {
                            SharingBatch(files)
                        }
                    }
                }
                .sheet(isPresented: $fileStore.showMove) {
                    let files = selectionToFiles()
                    if let destinationIDForMove, !files.isEmpty {
                        FileMove(files, to: destinationIDForMove)
                    }
                }
                .sheet(isPresented: $fileStore.showBrowserForCopy) {
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
                .sheet(isPresented: $fileStore.showCopy) {
                    let files = selectionToFiles()
                    if let destinationIDForCopy, !files.isEmpty {
                        FileCopy(files, to: destinationIDForCopy)
                    }
                }
                .sheet(isPresented: $fileStore.showRename) {
                    if !fileStore.selection.isEmpty {
                        FileRename(fileStore.selection.first!)
                    }
                }
                .sheet(isPresented: $fileStore.showDelete) {
                    if !fileStore.selection.isEmpty {
                        FileDelete(Array(fileStore.selection))
                    }
                }
                .sheet(isPresented: $fileStore.showDownload) {
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        FileDownload(files) { localURLs in
                            documentPickerURLs = localURLs
                            fileStore.showDownloadDocumentPicker = true
                        }
                    }
                }
                .sheet(isPresented: $fileStore.showDownloadDocumentPicker, onDismiss: handleDismissDownloadPicker) {
                    if let documentPickerURLs {
                        FileDownloadPicker(
                            sourceURLs: documentPickerURLs,
                            onCompletion: handleDismissDownloadPicker
                        )
                    }
                }
                .sheet(isPresented: $fileStore.showUploadDocumentPicker) {
                    FileUploadPicker { urls in
                        documentPickerURLs = urls
                        fileStore.showUploadDocumentPicker = false
                        fileStore.showUpload = true
                    }
                }
                .sheet(isPresented: $fileStore.showUpload) {
                    if let documentPickerURLs {
                        FileUpload(documentPickerURLs)
                    }
                }
                .sheet(isPresented: $fileStore.showNewFolder) {
                    if let parent = fileStore.file, let workspace = workspaceStore.current {
                        FolderNew(parentID: parent.id, workspaceId: workspace.id)
                    }
                }
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
