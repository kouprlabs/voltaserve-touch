import SwiftUI
import VoltaserveCore

struct SnapshotList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var snapshotStore = SnapshotStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    private let fileID: String

    init(fileID: String) {
        self.fileID = fileID
    }

    var body: some View {
        NavigationStack {
            if let entities = snapshotStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no snapshots.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { snapshot in
                                NavigationLink {
                                    SnapshotOverview(snapshot, snapshotStore: snapshotStore)
                                } label: {
                                    SnapshotRow(snapshot)
                                        .onAppear {
                                            onListItemAppear(snapshot.id)
                                        }
                                }
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Snapshots")
                .refreshable {
                    snapshotStore.fetchNext(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        if snapshotStore.isLoading, snapshotStore.entities != nil {
                            ProgressView()
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: snapshotStore.errorTitle,
            message: snapshotStore.errorMessage
        )
        .onAppear {
            snapshotStore.fileID = fileID
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
        .sync($snapshotStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        snapshotStore.fetchNext(replace: true)
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        snapshotStore.token = token
    }

    private func startTimers() {
        snapshotStore.startTimer()
    }

    private func stopTimers() {
        snapshotStore.stopTimer()
    }

    private func onListItemAppear(_ id: String) {
        if snapshotStore.isEntityThreshold(id) {
            snapshotStore.fetchNext()
        }
    }
}
