import SwiftUI
import VoltaserveCore

struct InsightsEntityList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var insightsStore = InsightsStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var searchText = ""
    private let fileID: String

    init(_ fileID: String) {
        self.fileID = fileID
    }

    var body: some View {
        NavigationView {
            if let entities = insightsStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no entities.")
                    } else {
                        List {
                            ForEach(entities, id: \.text) { entity in
                                InsightsEntityRow(entity)
                                    .onAppear {
                                        onListItemAppear(entity.text)
                                    }
                            }
                        }
                        .searchable(text: $searchText)
                        .onChange(of: insightsStore.searchText) {
                            insightsStore.searchPublisher.send($1)
                        }
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
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                onAppearOrChange()
            }
        }
        .onChange(of: insightsStore.query) {
            insightsStore.clear()
            insightsStore.fetchEntityNext()
        }
        .sync($insightsStore.searchText, with: $searchText)
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

    private func onListItemAppear(_ id: String) {
        if insightsStore.isEntityThreshold(id) {
            insightsStore.fetchEntityNext()
        }
    }
}
