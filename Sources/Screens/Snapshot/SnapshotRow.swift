import SwiftUI
import VoltaserveCore

struct SnapshotRow: View {
    private let snapshot: VOSnapshot.Entity

    init(_ snapshot: VOSnapshot.Entity) {
        self.snapshot = snapshot
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacingSm) {
            if snapshot.isActive {
                checkmark
            } else {
                spacer
            }
            VStack(alignment: .leading) {
                if let date = snapshot.createTime.date {
                    Text(date.pretty)
                }
                HStack {
                    ColorBadge("v\(snapshot.version)", color: .gray400, style: .outline)
                    if snapshot.hasFeatures() {
                        SnapshotFeatures(snapshot)
                    }
                }
            }
        }
    }

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundStyle(.blue)
            .fontWeight(.medium)
            .frame(width: 20, height: 20)
    }

    private var spacer: some View {
        Color.clear
            .frame(width: 20, height: 20)
    }
}
