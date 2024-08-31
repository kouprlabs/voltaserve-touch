import SwiftUI
import Voltaserve

struct FolderRow: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            Image("icon-folder")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(file.name)
                    .lineLimit(1)
                    .truncationMode(.middle)
                Text(file.createTime.relativeDate())
                    .foregroundStyle(.secondary)
            }
            Spacer()
            FileBadge(file)
        }
        .padding(VOMetrics.spacingSm)
    }
}
