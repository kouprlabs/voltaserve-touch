import SwiftUI

struct InsightsOverview: View {
    @State private var selection: Tag = .chart

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                Tab("Chart", systemImage: "chart.pie", value: Tag.chart) {
                    Text("Chart")
                }
                Tab("Entities", systemImage: "circle.grid.2x2", value: Tag.entities) {
                    Text("Entities")
                }
                Tab("Settings", systemImage: "gear", value: Tag.settings) {
                    Text("Settings")
                }
            }
        }
    }

    enum Tag {
        case chart
        case entities
        case settings
    }
}
