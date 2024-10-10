import Foundation
import SwiftUI
import WebKit

struct ViewerVideoWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context _: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context _: Context) {
        uiView.load(URLRequest(url: url))
    }
}
