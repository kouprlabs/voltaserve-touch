import SwiftUI
import VoltaserveCore

struct ViewerPDF: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var viewerPDFStore = ViewerPDFStore()
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if file.type == .file,
               let snapshot = file.snapshot,
               let download = snapshot.preview,
               let fileExtension = download.fileExtension, fileExtension.isPDF(),
               let url = viewerPDFStore.url {
                ViewerPDFWebView(url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .onAppear {
            viewerPDFStore.id = file.id
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
        viewerPDFStore.token = token
    }
}
