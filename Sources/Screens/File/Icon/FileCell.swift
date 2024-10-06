import SwiftUI
import VoltaserveCore

struct FileCell: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var fileStore: FileStore
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            if file.type == .file {
                if let snapshot = file.snapshot,
                   let thumbnail = snapshot.thumbnail,
                   let fileExtension = thumbnail.fileExtension,
                   let url = fileStore.urlForThumbnail(file.id, fileExtension: String(fileExtension.dropFirst())) {
                    FileCellThumbnail(url: url, file: file) {
                        fileIcon
                    }
                } else {
                    fileIcon
                }
            } else if file.type == .folder {
                folderIcon
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
        VStack {
            VStack {
                Image(file.iconForFile(colorScheme: colorScheme))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fileCellBadgeList(file)
                    .frame(width: FileCellMetrics.iconSize.width, height: FileCellMetrics.iconSize.height)
            }
            .frame(
                width: FileCellMetrics.iconSize.width + VOMetrics.spacingLg,
                height: FileCellMetrics.iconSize.height + VOMetrics.spacing2Xl
            )
            .background(colorScheme == .light ? .white : .clear)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
            .fileActions(file)
        }
        .frame(maxWidth: FileCellMetrics.frameSize.width, maxHeight: FileCellMetrics.frameSize.height)
    }

    private var folderIcon: some View {
        VStack {
            VStack {
                Image("icon-folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .fileCellBadgeList(file)
                    .frame(width: FileCellMetrics.iconSize.width, height: FileCellMetrics.iconSize.height)
            }
            .frame(
                width: FileCellMetrics.iconSize.width + VOMetrics.spacing2Xl,
                height: FileCellMetrics.iconSize.height + VOMetrics.spacingLg
            )
            .background(colorScheme == .light ? .white : .clear)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm))
            .fileActions(file)
        }
        .frame(maxWidth: FileCellMetrics.frameSize.width, maxHeight: FileCellMetrics.frameSize.height)
    }
}
