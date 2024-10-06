import SwiftUI
import VoltaserveCore

struct FileAdornments: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingXs) {
            if let isShared = file.isShared, isShared {
                FileBadge.shared
            }
            if file.snapshot?.mosaic != nil {
                FileBadge.mosaic
            }
            if file.snapshot?.entities != nil {
                FileBadge.insights
            }
        }
    }
}
