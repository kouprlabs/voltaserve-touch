import SwiftUI

struct OrganizationList: View {
    var organizations = [
        "Organization 1",
        "Organization 2",
        "Organization 3"
    ]

    var body: some View {
        NavigationStack {
            List(organizations, id: \.self) { organization in
                NavigationLink(organization) {
                    OrganizationMembers()
                        .navigationTitle(organization)
                }
            }
            .navigationTitle("Organizations")
        }
    }
}

#Preview {
    OrganizationList()
}
