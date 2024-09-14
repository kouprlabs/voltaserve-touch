import SwiftUI
import VoltaserveCore

struct FileCell: View {
    @Environment(\.colorScheme) private var colorScheme
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            if file.type == .file {
                Image(file.iconForFile(colorScheme: colorScheme))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
            } else if file.type == .folder {
                Image("icon-folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
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
        static let height = CGFloat(200)
    }
}
