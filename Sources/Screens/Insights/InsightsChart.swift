// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Charts
import SwiftUI
import VoltaserveCore

struct InsightsChart: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var insightsStore = InsightsStore(pageSize: Constants.pageSize)
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    private let fileID: String

    init(_ fileID: String) {
        self.fileID = fileID
    }

    var body: some View {
        NavigationView {
            if let entities = insightsStore.entities {
                Group {
                    if entities.count < 5 {
                        Text("Not enough data to render the chart.")
                    } else {
                        Chart(entities) { entity in
                            SectorMark(
                                angle: .value(
                                    Text(verbatim: entity.text),
                                    entity.frequency
                                ),
                                innerRadius: .ratio(0.6),
                                angularInset: 5
                            )
                            .foregroundStyle(
                                by: .value(
                                    Text(verbatim: entity.text),
                                    entity.text
                                )
                            )
                        }
                        .modifierIfPad {
                            $0.frame(maxWidth: 360, maxHeight: 360)
                        }
                        .padding(VOMetrics.spacing2Xl)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Insights")
                .refreshable {
                    insightsStore.fetchEntityNext(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: insightsStore.errorTitle,
            message: insightsStore.errorMessage
        )
        .onAppear {
            insightsStore.fileID = fileID
            if let token = tokenStore.token {
                assignTokenToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            insightsStore.clear()
            stopTimers()
        }
        .sync($insightsStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        insightsStore.fetchEntityNext(replace: true)
    }

    private func startTimers() {
        insightsStore.startTimer()
    }

    private func stopTimers() {
        insightsStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        insightsStore.token = token
    }

    private enum Constants {
        static let pageSize: Int = 5
    }
}
