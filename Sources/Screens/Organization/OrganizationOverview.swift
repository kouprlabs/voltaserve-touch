import SwiftUI
import VoltaserveCore

struct OrganizationOverview: View {
    @EnvironmentObject private var authStore: AuthStore
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
            if let token = authStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        organizationStore.token = token
    }
}

#Preview {
    OrganizationOverview(VOOrganization.Entity.devInstance)
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(OrganizationStore(VOOrganization.Entity.devInstance))
}
