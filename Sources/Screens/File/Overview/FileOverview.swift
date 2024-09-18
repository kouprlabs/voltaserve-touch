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
            fileStore.startTimer()
            if tokenStore.token != nil {
                onAppearOrChange()
                fileStore.token = tokenStore.token
            }
        }
        .onDisappear {
            fileStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
                fileStore.token = newToken
            }
        }
        .onChange(of: fileStore.query) {
            fileStore.clear()
            fileStore.fetchList(replace: true)
        }
        .environmentObject(fileStore)
    }

    private func onAppearOrChange() {
        fileStore.fetch()
        fileStore.fetchList(replace: true)
        fileStore.startTimer()
    }
}
