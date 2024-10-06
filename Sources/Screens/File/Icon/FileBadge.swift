import SwiftUI

struct FileBadge: View {
    @Environment(\.colorScheme) private var colorScheme

    static let shared = FileBadge("person.2.fill")
    static let mosaic = FileBadge("flame.fill")
    static let insights = FileBadge("eye.fill")

    private let icon: String

    init(_ icon: String) {
        self.icon = icon
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? Color.gray700 : .white)
                .stroke(colorScheme == .dark ? Color.gray600 : Color.gray300, lineWidth: 1)
                .frame(width: Constants.circleSize, height: Constants.circleSize)
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.orange)
                .frame(width: Constants.iconSize, height: Constants.iconSize)
        }
    }

    private enum Constants {
        static let circleSize: CGFloat = 25
        static let iconSize: CGFloat = 15
    }
}

#Preview {
    VStack {
        FileBadge.shared
        FileBadge.mosaic
        FileBadge.insights
    }
}
