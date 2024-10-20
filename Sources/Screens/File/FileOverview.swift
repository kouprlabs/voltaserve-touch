import Combine
import SwiftUI
import UIKit
import VoltaserveCore

struct FileOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var searchText = ""
    @State private var showError = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity, workspaceStore: WorkspaceStore) {
        self.file = file
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        VStack {
            if let entities = fileStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        if fileStore.viewMode == .list {
                            FileList(fileStore: fileStore, workspaceStore: workspaceStore)
                        } else if fileStore.viewMode == .grid {
                            FileGrid(fileStore: fileStore, workspaceStore: workspaceStore)
                        }
                    }
                }
                .searchable(text: $searchText)
                .onChange(of: fileStore.searchText) { fileStore.searchPublisher.send($1) }
                .refreshable { fileStore.fetchNext(replace: true) }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: fileStore.errorTitle,
            message: fileStore.errorMessage
        )
        .fileSheets(fileStore: fileStore, workspaceStore: workspaceStore)
        .fileToolbar(fileStore: fileStore)
        .onAppear {
            fileStore.current = file
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
            fileStore.fetchNext(replace: true)
        }
        .sync($fileStore.searchText, with: $searchText)
        .sync($fileStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        fileStore.fetch()
        fileStore.fetchNext(replace: true)
        fileStore.fetchTaskCount()
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
