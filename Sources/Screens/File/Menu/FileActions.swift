import SwiftUI
import VoltaserveCore

struct FileActions: ViewModifier {
    @ObservedObject private var fileStore: FileStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity, fileStore: FileStore) {
        self.file = file
        self.fileStore = fileStore
    }

    func body(content: Content) -> some View {
        content
            .fileContextMenu(
                file,
                fileStore: fileStore,
                onInsights: {
                    fileStore.showInsights = true
                },
                onMosaic: {
                    fileStore.showMosaic = true
                },
                onSharing: {
                    fileStore.showSharing = true
                },
                onSnapshots: {
                    fileStore.showSnapshots = true
                },
                onUpload: {
                    fileStore.showUploadDocumentPicker = true
                },
                onDownload: {
                    fileStore.showDownload = true
                },
                onDelete: {
                    fileStore.showDelete = true
                },
                onRename: {
                    fileStore.showRename = true
                },
                onMove: {
                    fileStore.showBrowserForMove = true
                },
                onCopy: {
                    fileStore.showBrowserForCopy = true
                },
                onOpen: {
                    if let snapshot = file.snapshot,
                       let fileExtension = snapshot.original.fileExtension,
                       let url = fileStore.urlForOriginal(file.id, fileExtension: String(fileExtension.dropFirst())) {
                        UIApplication.shared.open(url)
                    }
                }
            )
    }
}

extension View {
    func fileActions(_ file: VOFile.Entity, fileStore: FileStore) -> some View {
        modifier(FileActions(file, fileStore: fileStore))
    }
}
