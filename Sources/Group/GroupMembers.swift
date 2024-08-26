import SwiftUI
import Voltaserve

struct GroupMembers: View {
    var members: [VOUser.Entity] = [
        VOUser.Entity(
            id: UUID().uuidString,
            username: "bruceawayne@koupr.com",
            email: "bruceawayne@koupr.com",
            fullName: "Bruce Wayne",
            createTime: Date().ISO8601Format()
        ),
        VOUser.Entity(
            id: UUID().uuidString,
            username: "tonystark@koupr.com",
            email: "tonystark@koupr.com",
            fullName: "Tony Stark",
            createTime: Date().ISO8601Format()
        ),
        VOUser.Entity(
            id: UUID().uuidString,
            username: "natasharomanoff@koupr.com",
            email: "natasharomanoff@koupr.com",
            fullName: "Natasha Romanoff",
            createTime: Date().ISO8601Format()
        )
    ]

    var body: some View {
        List(members, id: \.id) { member in
            UserRow(member)
        }
    }
}

#Preview {
    GroupMembers()
}
