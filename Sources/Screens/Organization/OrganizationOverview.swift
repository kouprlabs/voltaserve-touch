import SwiftUI
import VoltaserveCore

struct OrganizationOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    private let organization: VOOrganization.Entity

    init(_ organization: VOOrganization.Entity, organizationStore: OrganizationStore) {
        self.organization = organization
        self.organizationStore = organizationStore
    }

    var body: some View {
        VStack {
            if let current = organizationStore.current {
                VStack {
                    VOAvatar(name: current.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            OrganizationMemberList(organizationStore: organizationStore)
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            InvitationOutgoingList(organization.id)
                        } label: {
                            Label("Invitations", systemImage: "paperplane")
                        }
                        NavigationLink {
                            OrganizationSettings(organizationStore: organizationStore) {
                                dismiss()
                            }
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(organization.name)
        .onAppear {
            organizationStore.current = organization
        }
    }
}
