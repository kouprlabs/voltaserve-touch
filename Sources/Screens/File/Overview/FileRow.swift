import SwiftUI
import VoltaserveCore

struct FileRow: View {
    @Environment(\.colorScheme) var colorScheme
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            if file.type == .file {
                Image(file.iconForFile(colorScheme: colorScheme))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            } else if file.type == .folder {
                Image("icon-folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            VStack(alignment: .leading) {
                Text(file.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(file.createTime.relativeDate())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            FileBadgeList(file)
                .padding(.trailing, VOMetrics.spacingMd)
        }
        .padding(VOMetrics.spacingSm)
    }
}
