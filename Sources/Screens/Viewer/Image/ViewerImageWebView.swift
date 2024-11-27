// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

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
            <html>
                <head>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
                    <style>
                        body, html {
                            margin: 0;
                            padding: 0;
                            background: #000;
                            display: flex;
                            justify-content: center;
                            align-items: center;
                            flex-grow: 1;
                            width: 100%;
                            height: 100%;
                            overflow: scroll;
                        }
                        img {
                            object-fit: contain;
                            max-width: 100%;
                            max-height: 100%;
                        }
                    </style>
                </head>
                <body>
                    <img src="\(url.absoluteString)" />
                </body>
            </html>
            """,
            baseURL: nil
        )
        return webView
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}
