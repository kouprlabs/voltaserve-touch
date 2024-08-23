import SwiftUI

struct GroupList: View {
    var groups = [
        "Group 1",
        "Group 2",
        "Group 3"
    ]

    var body: some View {
        NavigationStack {
            List(groups, id: \.self) { group in
                NavigationLink(group) {
                    GroupMembers()
                        .navigationTitle(group)
                }
            }
        }
    }
}

#Preview {
    GroupList()
}
