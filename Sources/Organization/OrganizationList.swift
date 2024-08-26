import SwiftUI

struct OrganizationList: View {
    var organizations = [
        "Organization Uno",
        "Organization Duo",
        "Organization Trio"
    ]

    var body: some View {
        NavigationStack {
            List(organizations, id: \.self) { organization in
                NavigationLink {
                    OrganizationMembers()
                        .navigationTitle(organization)
                } label: {
                    OrganizationRow(organization)
                }
            }
            .navigationTitle("Organizations")
        }
    }
}

#Preview {
    OrganizationList()
}
