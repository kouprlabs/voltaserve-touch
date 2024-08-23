import SwiftUI

struct GroupMembers: View {
    var members = [
        "Member 1",
        "Member 2",
        "Member 3"
    ]

    var body: some View {
        List(members, id: \.self) { member in
            Text(member)
        }
    }
}
