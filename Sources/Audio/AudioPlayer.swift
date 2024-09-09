import SwiftUI
import VoltaserveCore
import WebKit

struct AudioPlayer: View {
    @EnvironmentObject private var audioStore: AudioStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isAudio(),
           let url = audioStore.url(file.id, fileExtension: String(fileExtension.dropFirst())) {
            AudioWebView(url: url)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct AudioWebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
