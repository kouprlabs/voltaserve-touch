import SwiftUI

struct VOBadge: View {
    static let shared = VOBadge("person.2.fill")
    static let mosaic = VOBadge("flame.fill")
    static let insights = VOBadge("eye.fill")

    private let icon: String

    init(_ icon: String) {
        self.icon = icon
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .stroke(Color(.systemGray4), lineWidth: 1)
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
        VOBadge.shared
        VOBadge.mosaic
        VOBadge.insights
    }
}
