import SwiftUI
import VoltaserveCore

struct FileAdornments: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingXs) {
            if let snapshot = file.snapshot {
                if snapshot.status == .processing {
                    FileBadge.processing
                } else if snapshot.status == .waiting {
                    FileBadge.waiting
                } else if snapshot.status == .error {
                    FileBadge.error
                }
            }
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
