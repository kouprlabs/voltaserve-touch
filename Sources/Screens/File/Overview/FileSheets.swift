import SwiftUI
import VoltaserveCore

struct FileSheets: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @State private var documentPickerURLs: [URL]?

    // swiftlint:disable:next function_body_length
    func body(content: Content) -> some View {
        if let workspace = workspaceStore.current {
            content
                .sheet(isPresented: $fileStore.showBrowserForMove) {
                    NavigationStack {
                        BrowserList(workspace.rootID, confirmLabelText: "Move Here") {
                            fileStore.showMove = true
                            fileStore.showBrowserForMove = false
                        } onDismiss: {
                            fileStore.showBrowserForMove = false
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
                .sheet(isPresented: $fileStore.showMove) {
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        FileMove(files) {
                            fileStore.showMove = false
                        }
                    }
                }
                .sheet(isPresented: $fileStore.showBrowserForCopy) {
                    NavigationStack {
                        BrowserList(workspace.rootID, confirmLabelText: "Copy Here") {
                            fileStore.showCopy = true
                            fileStore.showBrowserForCopy = false
                        } onDismiss: {
                            fileStore.showBrowserForCopy = false
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(workspace.name)
                    }
                }
                .sheet(isPresented: $fileStore.showCopy) {
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        FileCopy(files) {
                            fileStore.showCopy = false
                        }
                    }
                }
                .sheet(isPresented: $fileStore.showRename) {
                    if !fileStore.selection.isEmpty {
                        FileRename(fileStore.selection.first!) {
                            fileStore.showRename = false
                        }
                    }
                }
                .sheet(isPresented: $fileStore.showDelete) {
                    if !fileStore.selection.isEmpty {
                        FileDelete(fileStore.selection) {
                            fileStore.showDelete = false
                        }
                    }
                }
                .sheet(isPresented: $fileStore.showDownload) {
                    let files = selectionToFiles()
                    if !files.isEmpty {
                        FileDownload(files) { localURLs in
                            fileStore.showDownload = false
                            documentPickerURLs = localURLs
                            fileStore.showDownloadDocumentPicker = true
                        } onDismiss: {
                            fileStore.showDownload = false
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
                        FileUpload(documentPickerURLs) {
                            fileStore.showUpload = false
                        }
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
