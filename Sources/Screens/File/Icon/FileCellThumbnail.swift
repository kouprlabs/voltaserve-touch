// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Kingfisher
import SwiftUI

private let customKingfisherManager: KingfisherManager = {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30
    config.timeoutIntervalForResource = 60
    let downloader = ImageDownloader(name: "custom.downloader")
    downloader.sessionConfiguration = config
    return KingfisherManager(downloader: downloader, cache: .default)
}()

public struct FileCellThumbnail<FallbackContent: View>: View {
    @ObservedObject private var fileStore: FileStore
    @Environment(\.colorScheme) private var colorScheme
    private let url: URL
    private let fallback: () -> FallbackContent
    private let file: VOFile.Entity

    public init(
        url: URL, file: VOFile.Entity, fileStore: FileStore, @ViewBuilder fallback: @escaping () -> FallbackContent
    ) {
        self.url = url
        self.fallback = fallback
        self.file = file
        self.fileStore = fileStore
    }

    public var body: some View {
        KFImage(url)
            .cacheOriginalImage()
            .placeholder {
                fallback()
            }
            .cancelOnDisappear(true)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
            .fileActions(file, fileStore: fileStore)
            .overlay {
                RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm)
                    .strokeBorder(Color.borderColor(colorScheme: colorScheme), lineWidth: 1)
            }
            .fileCellAdornments(file)
            .overlay {
                if let fileExtension = file.snapshot?.original.fileExtension, fileExtension.isVideo() {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .opacity(0.5)
                }
            }
            .frame(maxWidth: FileCellMetrics.frameSize.width, maxHeight: FileCellMetrics.frameSize.height)
    }
}
