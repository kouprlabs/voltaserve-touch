import SwiftUI
import VoltaserveCore

struct FileContextMenu: ViewModifier {
    var file: VOFile.Entity
    var onMove: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button {} label: {
                    Label("Insights", systemImage: "eye")
                }
                Button {} label: {
                    Label("Mosaic", systemImage: "flame")
                }
                Divider()
                Button {} label: {
                    Label("Sharing", systemImage: "person.2")
                }
                Button {} label: {
                    Label(
                        "Snapshots",
                        systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90"
                    )
                }
                Button {} label: {
                    Label("Upload", systemImage: "square.and.arrow.up")
                }
                Button {} label: {
                    Label("Download", systemImage: "square.and.arrow.down")
                }
                Divider()
                Button(role: .destructive) {} label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {} label: {
                    Label("Rename", systemImage: "pencil")
                }
                Button {
                    onMove?()
                } label: {
                    Label("Move", systemImage: "arrow.turn.up.right")
                }
                Button {} label: {
                    Label("Copy", systemImage: "document.on.document")
                }
            }
    }
}

extension View {
    func fileContextMenu(_ file: VOFile.Entity, onMove: (() -> Void)? = nil) -> some View {
        modifier(FileContextMenu(file: file, onMove: onMove))
    }
}
