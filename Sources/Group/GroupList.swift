import SwiftUI

struct GroupList: View {
    var groups = [
        "Group One",
        "Group Two",
        "Group Three"
    ]

    var body: some View {
        NavigationStack {
            List(groups, id: \.self) { group in
                NavigationLink {
                    GroupMembers()
                        .navigationTitle(group)
                } label: {
                    GroupRow(group)
                }
            }
            .navigationTitle("Groups")
        }
    }
}

#Preview {
    GroupList()
}
