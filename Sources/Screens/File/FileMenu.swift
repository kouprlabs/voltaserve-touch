import SwiftUI
import VoltaserveCore

struct FileMenu: View {
    @EnvironmentObject private var fileStore: FileStore
    private let selection: Set<String>
    private let onSharing: (() -> Void)?
    private let onSnapshots: (() -> Void)?
    private let onUpload: (() -> Void)?
    private let onDownload: (() -> Void)?
    private let onDelete: (() -> Void)?
    private let onRename: (() -> Void)?
    private let onMove: (() -> Void)?
    private let onCopy: (() -> Void)?

    init(
        _ selection: Set<String>,
        onSharing: (() -> Void)? = nil,
        onSnapshots: (() -> Void)? = nil,
        onUpload: (() -> Void)? = nil,
        onDownload: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onRename: (() -> Void)? = nil,
        onMove: (() -> Void)? = nil,
        onCopy: (() -> Void)? = nil
    ) {
        self.selection = selection
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
            if fileStore.isSharingAuthorized(selection) {
                Button { onSharing?() } label: {
                    Label("Sharing", systemImage: "person.2")
                }
                Divider()
            }
            if fileStore.isDeleteAuthorized(selection) {
                Button(role: .destructive) { onDelete?() } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            if fileStore.isMoveAuthorized(selection) {
                Button { onMove?() } label: {
                    Label("Move", systemImage: "arrow.turn.up.right")
                }
            }
            if fileStore.isCopyAuthorized(selection) {
                Button { onCopy?() } label: {
                    Label("Copy", systemImage: "document.on.document")
                }
            }
        } label: {
            Label("Menu", systemImage: "ellipsis.circle")
        }
    }
}
