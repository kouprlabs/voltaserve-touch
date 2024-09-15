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
                                        .stroke(Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255), lineWidth: 1)
                                }
                                .frame(maxWidth: 160, maxHeight: 160)
                        case .failure:
                            Image(file.iconForFile(colorScheme: colorScheme))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        @unknown default:
                            Image(file.iconForFile(colorScheme: colorScheme))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                        }
                    }
                } else {
                    Image(file.iconForFile(colorScheme: colorScheme))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
            } else if file.type == .folder {
                VStack {
                    Image("icon-folder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                }
                .frame(maxWidth: 160, maxHeight: 160)
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
        .frame(width: Constants.width, height: Constants.height)
    }

    enum Constants {
        static let width = CGFloat(160)
        static let height = CGFloat(260)
    }
}
