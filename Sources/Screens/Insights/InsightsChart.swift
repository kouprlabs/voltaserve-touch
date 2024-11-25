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

struct InsightsChart: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var insightsStore = InsightsStore(pageSize: Constants.pageSize)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    private let fileID: String

    init(_ fileID: String) {
        self.fileID = fileID
    }

    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = insightsStore.entities {
                    Group {
                        if entities.count < 5 {
                            Text("Not enough data to render the chart.")
                        } else {
                            Chart(Array(entities.enumerated()), id: \.element.id) { index, entity in
                                SectorMark(
                                    angle: .value(
                                        Text(verbatim: entity.text),
                                        entity.frequency
                                    ),
                                    innerRadius: .ratio(0.65),
                                    angularInset: 4
                                )
                                .cornerRadius(5)
                                .foregroundStyle(sectorMarkColor)
                                .annotation(position: .overlay) {
                                    Text("\(entity.text) (\(entity.frequency))")
                                        .font(.footnote)
                                        .padding(.horizontal)
                                        .frame(height: 20)
                                        .background(Color(UIColor.systemBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(sectorMarkColor, lineWidth: 1)
                                        }
                                }
                            }
                            .chartLegend(.hidden)
                            .frame(maxWidth: 300, maxHeight: 300)
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Insights")
                    .refreshable {
                        insightsStore.fetchEntityNextPage(replace: true)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
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
    }

    private var sectorMarkColor: Color {
        colorScheme == .dark ? .gray500 : .gray200
    }

    private enum Constants {
        static let pageSize: Int = 5
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        insightsStore.entitiesIsLoadingFirstTime
    }

    var error: String? {
        insightsStore.entitiesError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        insightsStore.fetchEntityNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        insightsStore.startTimer()
    }

    func stopTimers() {
        insightsStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        insightsStore.token = token
    }
}
