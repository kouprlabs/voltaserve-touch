import SwiftUI
import VoltaserveCore

struct FileBadge: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingXs) {
            if let isShared = file.isShared, isShared {
                VOBadge.shared
            }
            if file.snapshot?.mosaic != nil {
                VOBadge.mosaic
            }
            if file.snapshot?.entities != nil {
                VOBadge.insights
            }
        }
    }
}
