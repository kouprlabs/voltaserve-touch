import SwiftUI
import VoltaserveCore

struct ViewerAudio: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var viewerAudioStore = ViewerAudioStore()
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if file.type == .file,
               let snapshot = file.snapshot,
               let download = snapshot.preview,
               let fileExtension = download.fileExtension, fileExtension.isAudio(),
               let url = viewerAudioStore.url {
                ViewerAudioWebView(url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .onAppear {
            viewerAudioStore.id = file.id
            if let fileExtension = file.snapshot?.preview?.fileExtension {
                viewerAudioStore.fileExtension = String(fileExtension.dropFirst())
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
        viewerAudioStore.token = token
    }
}
