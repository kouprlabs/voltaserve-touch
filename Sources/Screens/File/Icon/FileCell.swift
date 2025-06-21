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
import VoltaserveCore

public struct FileCell: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var fileStore: FileStore
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity, fileStore: FileStore) {
        self.file = file
        self.fileStore = fileStore
    }

    public var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            if file.type == .file {
                if let snapshot = file.snapshot,
                    let thumbnail = snapshot.thumbnail,
                    let fileExtension = thumbnail.fileExtension,
                    let url = fileStore.urlForThumbnail(file.id, fileExtension: String(fileExtension.dropFirst()))
                {
                    FileCellThumbnail(url: url, file: file, fileStore: fileStore) {
                        fileIcon
                    }
                } else {
                    fileCell
                }
            } else if file.type == .folder {
                folderCell
            }
            VStack {
                Text(file.name)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .truncationMode(.middle)
                Text(file.createTime.relativeDate())
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                Spacer()
            }
        }
        .frame(width: FileCellMetrics.cellSize.width, height: FileCellMetrics.cellSize.height)
    }

    private var fileIcon: some View {
        Image(file.iconForFile(colorScheme: colorScheme))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: FileCellMetrics.iconSize.width, height: FileCellMetrics.iconSize.height)
    }

    private var fileCell: some View {
        VStack {
            VStack {
                fileIcon
                    .fileCellAdornments(file)
            }
            .frame(
                width: FileCellMetrics.iconSize.width + VOMetrics.spacingLg,
                height: FileCellMetrics.iconSize.height + VOMetrics.spacing2Xl
            )
            .background(colorScheme == .light ? .white : .clear)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
            .fileActions(file, fileStore: fileStore)
        }
        .frame(maxWidth: FileCellMetrics.frameSize.width, maxHeight: FileCellMetrics.frameSize.height)
    }

    private var folderIcon: some View {
        Image("icon-folder")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: FileCellMetrics.iconSize.width, height: FileCellMetrics.iconSize.height)
    }

    private var folderCell: some View {
        VStack {
            VStack {
                folderIcon
                    .fileCellAdornments(file)
            }
            .frame(
                width: FileCellMetrics.iconSize.width + VOMetrics.spacing2Xl,
                height: FileCellMetrics.iconSize.height + VOMetrics.spacingLg
            )
            .background(colorScheme == .light ? .white : .clear)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
            .fileActions(file, fileStore: fileStore)
        }
        .frame(maxWidth: FileCellMetrics.frameSize.width, maxHeight: FileCellMetrics.frameSize.height)
    }
}
