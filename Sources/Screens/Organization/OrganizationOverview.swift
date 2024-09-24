import SwiftUI
import VoltaserveCore

struct OrganizationOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
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
                            OrganizationMemberList()
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            InvitationListOutgoing()
                        } label: {
                            Label("Invitations", systemImage: "paperplane")
                        }
                        NavigationLink {
                            OrganizationSettings {
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
        .onAppear {
            organizationStore.current = organization
        }
    }
}
