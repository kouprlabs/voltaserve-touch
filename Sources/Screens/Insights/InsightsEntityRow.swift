import SwiftUI
import VoltaserveCore

struct InsightsEntityRow: View {
    private let entity: VOInsights.Entity

    init(_ entity: VOInsights.Entity) {
        self.entity = entity
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            Text(entity.text)
                .lineLimit(1)
                .truncationMode(.tail)
            ColorBadge("\(entity.frequency)", color: .gray300, style: .fill)
        }
    }
}
