import GLTFKit2
import SceneKit
import SwiftUI
import VoltaserveCore

struct Viewer3D: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var viewer3DStore = Viewer3DStore()
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if file.type == .file,
               let snapshot = file.snapshot,
               let download = snapshot.preview,
               let fileExtension = download.fileExtension, fileExtension.isGLB(),
               let url = viewer3DStore.url {
                Viewer3DRenderer(file: file, url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .onAppear {
            viewer3DStore.id = file.id
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
        viewer3DStore.token = token
    }
}
