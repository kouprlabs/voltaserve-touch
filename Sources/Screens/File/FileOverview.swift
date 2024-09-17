import Combine
import SwiftUI
import UIKit
import VoltaserveCore

struct FileOverview: View {
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var authStore: AuthStore

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
        .alert(VOTextConstants.errorAlertTitle, isPresented: $fileStore.showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            if let errorMessage = fileStore.errorMessage {
                Text(errorMessage)
            }
        }
        .fileSheets()
        .fileToolbar()
        .onAppear {
            fileStore.id = id
            fileStore.clear()
            if authStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            fileStore.stopTimer()
        }
        .onChange(of: authStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: fileStore.query) {
            fileStore.clear()
            fileStore.fetchList(replace: true)
        }
    }

    private func onAppearOrChange() {
        fileStore.fetch()
        fileStore.fetchList(replace: true)
        fileStore.startTimer()
    }
}
