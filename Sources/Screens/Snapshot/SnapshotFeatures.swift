import SwiftUI
import VoltaserveCore

struct SnapshotFeatures: View {
    private let snapshot: VOSnapshot.Entity

    init(_ snapshot: VOSnapshot.Entity) {
        self.snapshot = snapshot
    }

    var body: some View {
        HStack {
            if snapshot.entities != nil {
                ColorBadge("Insights", color: .gray400, style: .outline)
            }
            if snapshot.mosaic != nil {
                ColorBadge("Mosaic", color: .gray400, style: .outline)
            }
        }
    }
}

extension VOSnapshot.Entity {
    func hasFeatures() -> Bool {
        entities != nil || mosaic != nil
    }

    func hasEntities() -> Bool {
        entities != nil
    }

    func hasMosaic() -> Bool {
        mosaic != nil
    }
}
