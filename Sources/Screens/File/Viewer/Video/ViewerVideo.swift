import SwiftUI
import VoltaserveCore

struct ViewerVideo: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var viewerVideoStore = ViewerVideoStore()
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if file.type == .file,
               let snapshot = file.snapshot,
               let download = snapshot.preview,
               let fileExtension = download.fileExtension, fileExtension.isVideo(),
               let url = viewerVideoStore.url {
                ViewerVideoWebView(url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .onAppear {
            viewerVideoStore.id = file.id
            if let fileExtension = file.snapshot?.preview?.fileExtension {
                viewerVideoStore.fileExtension = String(fileExtension.dropFirst())
            }
            if let token = tokenStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        viewerVideoStore.token = token
    }
}
