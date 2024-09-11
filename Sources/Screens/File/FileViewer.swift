import SwiftUI
import VoltaserveCore

struct FileViewer: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var pdfStore: PDFStore
    @EnvironmentObject private var imageStore: ImageStore
    @EnvironmentObject private var videoStore: VideoStore
    @EnvironmentObject private var audioStore: AudioStore
    @EnvironmentObject private var glbStore: GLBStore
    @EnvironmentObject private var mosaicStore: MosaicStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            PDFViewer(file)
            ImageViewer(file)
            VideoPlayer(file)
            AudioPlayer(file)
            GLBViewer(file)
            if UIDevice.current.userInterfaceIdiom == .pad {
                MosaicViewer(file)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                MosaicViewer(file)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(file.name)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
        .onAppear {
            if let token = authStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        pdfStore.token = token
        imageStore.token = token
        videoStore.token = token
        audioStore.token = token
        glbStore.token = token
        mosaicStore.token = token
    }
}
