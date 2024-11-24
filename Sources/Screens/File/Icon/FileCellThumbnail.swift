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

struct FileCellThumbnail<FallbackContent: View>: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.colorScheme) private var colorScheme
    private let url: URL
    private let fallback: () -> FallbackContent
    private let file: VOFile.Entity

    init(
        url: URL, file: VOFile.Entity, fileStore: FileStore,
        @ViewBuilder fallback: @escaping () -> FallbackContent
    ) {
        self.url = url
        self.fallback = fallback
        self.file = file
        self.fileStore = fileStore
    }

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
                .contentShape(
                    .contextMenuPreview, RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm)
                )
                .fileActions(file, fileStore: fileStore)
                .overlay {
                    RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm)
                        .stroke(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
                }
                .fileCellAdornments(file)
                .overlay {
                    if let fileExtension = file.snapshot?.original.fileExtension,
                        fileExtension.isVideo()
                    {
                        Image(systemName: "play.fill")
                            .foregroundStyle(.white)
                            .font(.largeTitle)
                            .opacity(0.5)
                    }
                }
                .frame(
                    maxWidth: FileCellMetrics.frameSize.width,
                    maxHeight: FileCellMetrics.frameSize.height)
        } placeholder: {
            fallback()
        }
    }
}
