import SwiftUI
import VoltaserveCore

struct FileMenu: View {
    @EnvironmentObject private var fileStore: FileStore
    private let ids: Set<String>
    private let onSharing: (() -> Void)?
    private let onSnapshots: (() -> Void)?
    private let onUpload: (() -> Void)?
    private let onDownload: (() -> Void)?
    private let onDelete: (() -> Void)?
    private let onRename: (() -> Void)?
    private let onMove: (() -> Void)?
    private let onCopy: (() -> Void)?

    init(
        _ ids: Set<String>,
        onSharing: (() -> Void)? = nil,
        onSnapshots: (() -> Void)? = nil,
        onUpload: (() -> Void)? = nil,
        onDownload: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onRename: (() -> Void)? = nil,
        onMove: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil
    ) {
        self.ids = ids
        self.onSharing = onSharing
        self.onSnapshots = onSnapshots
        self.onUpload = onUpload
        self.onDownload = onDownload
        self.onDelete = onDelete
        self.onRename = onRename
        self.onMove = onMove
        self.onCopy = onCopy
    }

    var body: some View {
        Menu {
            if fileStore.isSharingAuthorized(ids) {
                Button {
                    onSharing?()
                } label: {
                    Label("Sharing", systemImage: "person.2")
                }
            }
            if fileStore.isDownloadAuthorized(ids) {
                Button {
                    onDownload?()
                } label: {
                    Label("Download", systemImage: "square.and.arrow.down")
                }
            }
            if fileStore.isSharingAuthorized(ids) ||
                fileStore.isDownloadAuthorized(ids) {
                Divider()
            }
            if fileStore.isDeleteAuthorized(ids) {
                Button(role: .destructive) {
                    onDelete?()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            if fileStore.isMoveAuthorized(ids) {
                Button {
                    onMove?()
                } label: {
                    Label("Move", systemImage: "arrow.turn.up.right")
                }
            }
            if fileStore.isCopyAuthorized(ids) {
                Button {
                    onCopy?()
                } label: {
                    Label("Copy", systemImage: "document.on.document")
                }
            }
        } label: {
            Label("Menu", systemImage: "ellipsis.circle")
        }
    }
}
