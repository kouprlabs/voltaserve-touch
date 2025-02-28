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

struct Viewer: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var isImmersiveMode: Bool = false
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        NavigationView {
            VStack {
                ViewerPDF(file)
                ViewerImage(file)
                ViewerVideo(file)
                ViewerAudio(file)
                Viewer3D(file)
                ViewerMosaic(file)
                ViewerOCR(file)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(file.name)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
