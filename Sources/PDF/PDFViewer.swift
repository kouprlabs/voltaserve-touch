import SwiftUI
import VoltaserveCore
import WebKit

struct PDFViewer: View {
    @EnvironmentObject private var pdfStore: PDFStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isPDF(),
           let url = pdfStore.url(file.id) {
            PDFWebView(url: url)
                .edgesIgnoringSafeArea(.horizontal)
        }
    }
}

struct PDFWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.load(URLRequest(url: url))
    }
}
