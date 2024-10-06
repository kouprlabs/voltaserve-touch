import SwiftUI
import VoltaserveCore

struct FileCellAdornments: ViewModifier {
    var file: VOFile.Entity

    func body(content: Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            FileAdornments(file)
                .offset(x: FileCellMetrics.badgeOffset.width, y: FileCellMetrics.badgeOffset.height)
        }
    }
}

extension View {
    func fileCellAdornments(_ file: VOFile.Entity) -> some View {
        modifier(FileCellAdornments(file: file))
    }
}
