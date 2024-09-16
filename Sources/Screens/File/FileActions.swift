import SwiftUI
import VoltaserveCore

struct FileActions: ViewModifier {
    @EnvironmentObject private var fileStore: FileStore
    var file: VOFile.Entity
    var list: FileList

    init(_ file: VOFile.Entity, list: FileList) {
        self.file = file
        self.list = list
    }

    func body(content: Content) -> some View {
        content
            .fileContextMenu(
                file,
                selection: list.$selection,
                onUpload: { list.showUploadDocumentPicker = true },
                onDownload: { list.showDownload = true },
                onDelete: { list.showDelete = true },
                onRename: { list.showRename = true },
                onMove: { list.showBrowserForMove = true },
                onCopy: { list.showBrowserForCopy = true },
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
    func fileActions(_ file: VOFile.Entity, list: FileList) -> some View {
        modifier(FileActions(file, list: list))
    }
}
