import SwiftUI
import VoltaserveCore
import WebKit

struct ViewerPDF: View {
    @EnvironmentObject private var store: ViewerPDFStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isPDF(),
           let url = store.url(file.id) {
            PDFWebView(url: url)
        }
    }
}

struct PDFWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
