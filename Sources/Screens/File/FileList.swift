import Combine
import SwiftUI
import UIKit
import VoltaserveCore

struct FileList: View {
    @EnvironmentObject var fileStore: FileStore
    @EnvironmentObject private var authStore: AuthStore
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            if let entities = fileStore.entities {
                if entities.count == 0 {
                    Text("There are no items.")
                } else {
                    if fileStore.viewMode == .list {
                        listView(entities)
                    } else if fileStore.viewMode == .grid {
                        gridView(entities)
                    }
                }
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
        .fileToolbar(self)
        .onAppear {
            fileStore.id = id
            fileStore.clear()
            fileStore.createSearchPublisher()
            if authStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            fileStore.stopTimer()
            fileStore.destroySearchPublisher()
        }
        .onChange(of: authStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: fileStore.query) {
            fileStore.fetchList(replace: true)
        }
    }

    private func onAppearOrChange() {
        fileStore.fetch()
        fileStore.fetchList(replace: true)
        fileStore.startTimer()
    }

    func onListItemAppear(_ id: String) {
        if fileStore.isLast(id) {
            fileStore.fetchList()
        }
    }
}
