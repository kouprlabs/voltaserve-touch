import SwiftUI
import VoltaserveCore

struct InsightsOverview: View {
    @State private var selection: Tag = .chart
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Chart", systemImage: "chart.pie", value: Tag.chart) {
                InsightsChart(file.id)
            }
            Tab("Entities", systemImage: "circle.grid.2x2", value: Tag.entities) {
                InsightsEntityList(file.id)
            }
            Tab("Settings", systemImage: "gear", value: Tag.settings) {
                InsightsSettings(file)
            }
        }
    }

    enum Tag {
        case chart
        case entities
        case settings
    }
}
