import SwiftUI
import VoltaserveCore

struct ViewerImage: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var viewerImageStore = ViewerImageStore()
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if file.type == .file,
               let snapshot = file.snapshot, snapshot.mosaic == nil,
               let download = snapshot.preview,
               let fileExtension = download.fileExtension, fileExtension.isImage(),
               let url = viewerImageStore.url {
                ViewerImageWebView(url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .onAppear {
            viewerImageStore.id = file.id
            if let fileExtension = file.snapshot?.preview?.fileExtension {
                viewerImageStore.fileExtension = String(fileExtension.dropFirst())
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
        viewerImageStore.token = token
    }
}
