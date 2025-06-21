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

public struct InsightsOverview: View {
    @State private var selection: Tag = .chart
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity) {
        self.file = file
    }

    public var body: some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            TabView(selection: $selection) {
                Tab("Chart", systemImage: "chart.pie", value: Tag.chart) {
                    InsightsChart(file)
                }
                if let snapshot = file.snapshot, snapshot.capabilities.entities {
                    Tab("Entities", systemImage: "circle.grid.2x2", value: Tag.entities) {
                        InsightsEntityList(file)
                    }
                }
                Tab("Settings", systemImage: "gear", value: Tag.settings) {
                    InsightsSettings(file)
                }
            }
        }
    }

    public enum Tag {
        case chart
        case entities
        case settings
    }
}
