import SwiftUI
import VoltaserveCore
import WebKit

struct VideoPlayer: View {
    @EnvironmentObject private var videoStore: VideoStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isVideo(),
           let url = videoStore.url(file.id, fileExtension: String(fileExtension.dropFirst())) {
            VideoWebView(url: url)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct VideoWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.load(URLRequest(url: url))
    }
}
