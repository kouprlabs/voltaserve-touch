import SwiftUI
import VoltaserveCore

struct OrganizationOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    private let organization: VOOrganization.Entity

    init(_ organization: VOOrganization.Entity) {
        self.organization = organization
    }

    var body: some View {
        VStack {
            if let current = organizationStore.current {
                VStack {
                    VOAvatar(name: current.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            OrganizationMembers()
                                .navigationTitle("Members")
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            OrganizationSettings {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .navigationTitle("Settings")
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            organizationStore.current = organization
        }
    }
}
