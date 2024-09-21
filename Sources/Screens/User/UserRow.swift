import SwiftUI
import UIKit
import VoltaserveCore

struct VOUserRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let user: VOUser.Entity

    init(_ user: VOUser.Entity) {
        self.user = user
    }

    var body: some View {
        HStack(spacing: 15) {
            VOAvatar(name: user.fullName, size: 45, base64Image: user.picture)
            VStack(alignment: .leading) {
                Text(user.fullName)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text(user.email)
                    .font(.footnote)
                    .foregroundStyle(.gray)
            }
        }
    }
}

#Preview {
    VOUserRow(VOUser.Entity(
        id: UUID().uuidString,
        username: "brucelee@example.com",
        email: "brucelee@example.com",
        fullName: "Bruce Lee",
        createTime: Date().ISO8601Format()
    ))
}
