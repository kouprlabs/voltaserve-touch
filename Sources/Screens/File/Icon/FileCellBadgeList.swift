import SwiftUI
import VoltaserveCore

struct FileCellBadgeList: ViewModifier {
    var file: VOFile.Entity

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            FileBadgeList(file)
                .offset(x: FileCellMetrics.badgeOffset.width, y: FileCellMetrics.badgeOffset.height)
        }
    }
}

extension View {
    func fileCellBadgeList(_ file: VOFile.Entity) -> some View {
        modifier(FileCellBadgeList(file: file))
    }
}
