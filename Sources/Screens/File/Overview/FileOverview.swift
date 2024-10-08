import Combine
import SwiftUI
import UIKit
import VoltaserveCore

struct FileOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @State private var searchText = ""
    @State private var showError = false

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
                .searchable(text: $searchText)
                .onChange(of: fileStore.searchText) { fileStore.searchPublisher.send($1) }
                .refreshable { fileStore.fetchList(replace: true) }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
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
        .onChange(of: fileStore.query) {
            fileStore.clear()
            fileStore.fetchList(replace: true)
        }
        .sync($fileStore.searchText, with: $searchText)
        .sync($fileStore.showError, with: $showError)
        .environmentObject(fileStore)
    }

    private func onAppearOrChange() {
        fetchData()
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
