import SwiftUI
import UIKit
import Voltaserve

struct VOUserRow: View {
    private let user: VOUser.Entity

    init(_ user: VOUser.Entity) {
        self.user = user
    }

    var body: some View {
        HStack(spacing: 15) {
            VOAvatar(name: user.fullName, size: 45, base64Image: user.picture)
            VStack(alignment: .leading) {
                Text(user.fullName)
                Text(user.email)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
