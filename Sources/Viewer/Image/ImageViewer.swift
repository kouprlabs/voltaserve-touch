import SwiftUI
import VoltaserveCore
import WebKit

struct ImageViewer: View {
    @EnvironmentObject private var store: ImageStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot, snapshot.mosaic == nil,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isImage(),
           let url = store.url(file.id, fileExtension: String(fileExtension.dropFirst())) {
            ImageWebView(url: url)
        }
    }
}

struct ImageWebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context _: Context) -> WKWebView {
        let webView = WKWebView()
        webView.loadHTMLString(
            """
            <!DOCTYPE html>
            <html lang="en">
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
                    <style>
                        body, html {
                            margin: 0;
                            padding: 0;
                            height: 100%;
                            background: #000;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                        }
                        img {
                            width: 100%;
                            height: auto;
                        }
                    </style>
                </head>
                <body>
                    <img src="\(url.absoluteString)" alt="Image">
                </body>
            </html>
            """, baseURL: nil
        )
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {
        // No additional updates needed
    }
}
