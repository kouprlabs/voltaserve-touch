import Combine
import SwiftUI
import UIKit
import VoltaserveCore

struct FileOverview: View {
    @StateObject private var fileStore = FileStore()
    @EnvironmentObject private var tokenStore: TokenStore

    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            if let entities = fileStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        if fileStore.viewMode == .list {
                            FileList()
                        } else if fileStore.viewMode == .grid {
                            FileGrid()
                        }
                    }
                }
                .searchable(text: $fileStore.searchText)
                .onChange(of: fileStore.searchText) { fileStore.searchPublisher.send($1) }
                .refreshable { fileStore.fetchList(replace: true) }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $fileStore.showError,
            title: fileStore.errorTitle,
            message: fileStore.errorMessage
        )
        .fileSheets()
        .fileToolbar()
        .onAppear {
            fileStore.id = id
            fileStore.loadViewModeFromUserDefaults()
            if let token = tokenStore.token {
                assignTokenToStores(token)
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
        .onChange(of: fileStore.query) {
            fileStore.clear()
            fileStore.fetchList(replace: true)
        }
        .environmentObject(fileStore)
    }

    private func onAppearOrChange() {
        fetchData()
        startTimers()
    }

    private func fetchData() {
        fileStore.fetch()
        fileStore.fetchList(replace: true)
    }

    private func startTimers() {
        fileStore.startTimer()
    }

    private func stopTimers() {
        fileStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }
}
