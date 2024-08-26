import SwiftUI
import Voltaserve

struct UserRow: View {
    var user: VOUser.Entity

    init(_ user: VOUser.Entity) {
        self.user = user
    }

    var body: some View {
        HStack(spacing: 15) {
            Avatar(name: user.fullName, size: 45)
            VStack(alignment: .leading) {
                Text(user.fullName)
                Text(user.email)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
            }
        }
    }
}

#Preview {
    UserRow(VOUser.Entity(
        id: UUID().uuidString,
        username: "brucelee@example.com",
        email: "brucelee@example.com",
        fullName: "Bruce Lee",
        createTime: Date().ISO8601Format()
    ))
}
