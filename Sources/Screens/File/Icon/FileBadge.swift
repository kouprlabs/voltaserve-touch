import SwiftUI

struct FileBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    private let icon: String
    static let shared = FileBadge(Icons.shared)
    static let mosaic = FileBadge(Icons.mosaic)
    static let insights = FileBadge(Icons.insights)
    static let processing = FileBadge(Icons.processing)
    static let error = FileBadge(Icons.error)
    static let waiting = FileBadge(Icons.waiting)

    init(_ icon: String) {
        self.icon = icon
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color.gray700 : .white)
                .stroke(colorScheme == .dark ? Color.gray600 : Color.gray300, lineWidth: 1)
                .frame(width: Constants.circleSize, height: Constants.circleSize)
            if icon == Icons.processing {
                Image(systemName: Icons.processing)
                    .symbolEffect(.rotate, options: .repeat(.continuous))
                    .symbolRenderingMode(.palette)
                    .font(.title2)
                    .foregroundStyle(Color.gray400, colorScheme == .dark ? Color.gray700 : .white)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            } else if icon == Icons.error {
                Image(systemName: Icons.error)
                    .symbolRenderingMode(.palette)
                    .font(.title2)
                    .foregroundStyle(Color.red500, colorScheme == .dark ? Color.gray700 : .white)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            } else if icon == Icons.waiting {
                Image(systemName: Icons.waiting)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(Color.gray400)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.orange)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            }
        }
    }

    private enum Constants {
        static let circleSize: CGFloat = 25
        static let iconSize: CGFloat = 15
    }

    private enum Icons {
        static let shared = "person.2.fill"
        static let mosaic = "flame.fill"
        static let insights = "eye.fill"
        static let processing = "arrow.trianglehead.2.clockwise.rotate.90.circle.fill"
        static let error = "xmark.circle.fill"
        static let waiting = "hourglass"
    }
}

#Preview {
    VStack {
        FileBadge.shared
        FileBadge.mosaic
        FileBadge.insights
        FileBadge.processing
        FileBadge.waiting
        FileBadge.error
    }
}
