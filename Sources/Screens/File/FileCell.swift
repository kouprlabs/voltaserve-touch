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
                    FileThumbnail(url: url) { fileIcon }
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
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .frame(width: FileMetrics.cellSize.width, height: FileMetrics.cellSize.height)
    }

    private var fileIcon: some View {
        VStack {
            Image(file.iconForFile(colorScheme: colorScheme))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: FileMetrics.iconSize.width, height: FileMetrics.iconSize.height)
        }
        .frame(maxWidth: FileMetrics.frameSize.width, maxHeight: FileMetrics.frameSize.height)
    }

    private var folderIcon: some View {
        VStack {
            Image("icon-folder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: FileMetrics.iconSize.width, height: FileMetrics.iconSize.height)
        }
        .frame(maxWidth: FileMetrics.frameSize.width, maxHeight: FileMetrics.frameSize.height)
    }
}

struct FileThumbnail<FallbackContent: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    var url: URL
    var fallback: () -> FallbackContent

    init(url: URL, @ViewBuilder fallback: @escaping () -> FallbackContent) {
        self.url = url
        self.fallback = fallback
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(VOMetrics.borderRadiusSm)
                    .overlay {
                        RoundedRectangle(cornerRadius: VOMetrics.borderRadiusSm)
                            .stroke(borderColor(), lineWidth: 1)
                    }
                    .frame(maxWidth: FileMetrics.frameSize.width, maxHeight: FileMetrics.frameSize.height)
            case .failure:
                fallback()
            @unknown default:
                fallback()
            }
        }
    }

    private func borderColor() -> Color {
        if colorScheme == .dark {
            Color(.sRGB, red: 255 / 255, green: 255 / 255, blue: 255 / 255, opacity: 0.16)
        } else {
            Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
        }
    }
}

enum FileMetrics {
    static let iconSize = CGSize(width: 80, height: 80)
    static let frameSize = CGSize(width: 160, height: 160)
    static let cellSize = CGSize(width: 160, height: 260)
}
