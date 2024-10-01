import SwiftUI
import VoltaserveCore

struct SharingUserRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let userPermission: VOFile.UserPermission

    init(_ userPermission: VOFile.UserPermission) {
        self.userPermission = userPermission
    }

    var body: some View {
        HStack(spacing: VOMetrics.spacing) {
            VOAvatar(
                name: userPermission.user.fullName,
                size: VOMetrics.avatarSize,
                base64Image: userPermission.user.picture
            )
            VStack(alignment: .leading) {
                Text(userPermission.user.fullName)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(userPermission.user.email)
                    .font(.footnote)
                    .foregroundStyle(Color.gray500)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            Spacer()
            SharingPermissionBadge(userPermission.permission)
        }
    }
}

#Preview {
    SharingUserRow(.init(
        id: UUID().uuidString,
        user: VOUser.Entity(
            id: UUID().uuidString,
            username: "brucelee@example.com",
            email: "brucelee@example.com",
            fullName: "Bruce Lee",
            createTime: Date().ISO8601Format()
        ),
        permission: .editor
    ))
}
