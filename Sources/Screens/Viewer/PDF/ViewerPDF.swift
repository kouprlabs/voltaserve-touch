// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI
import VoltaserveCore

struct ViewerPDF: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var viewerPDFStore = ViewerPDFStore()
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if file.type == .file,
                let snapshot = file.snapshot,
                let download = snapshot.preview,
                let fileExtension = download.fileExtension, fileExtension.isPDF(),
                let url = viewerPDFStore.url
            {
                ViewerPDFWebView(url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .onAppear {
            viewerPDFStore.id = file.id
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
        viewerPDFStore.token = token
    }
}
