import SwiftUI
import VoltaserveCore

struct FileActions: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    func body(content: Content) -> some View {
        content
            .fileContextMenu(
                file,
                onSharing: {
                    fileStore.showSharing = true
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
    func fileActions(_ file: VOFile.Entity) -> some View {
        modifier(FileActions(file))
    }
}
