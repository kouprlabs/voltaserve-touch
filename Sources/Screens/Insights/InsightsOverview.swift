// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

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
