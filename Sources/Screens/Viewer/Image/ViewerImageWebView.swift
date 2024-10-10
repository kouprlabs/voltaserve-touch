import Foundation
import SwiftUI
import WebKit

struct ViewerImageWebView: UIViewRepresentable {
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
            """,
            baseURL: nil
        )
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}
