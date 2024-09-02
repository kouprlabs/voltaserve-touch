import SwiftUI
import Voltaserve

struct OrganizationMembers: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage: String?
    private let organization: VOOrganization.Entity

    init(_ organization: VOOrganization.Entity) {
        self.organization = organization
    }

    var body: some View {
        VStack {
            if let members = organizationStore.members {
                List(members.data, id: \.id) { member in
                    VOUserRow(member)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                    ToolbarItem(placement: .topBarLeading) {
                        Button {} label: {
                            Label("Add Members", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    OrganizationSettings()
                }
                .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                    Button(VOTextConstants.errorAlertButtonLabel) {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            organizationStore.current = organization
            if let token = authStore.token {
                organizationStore.token = token
                fetchMembers()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                organizationStore.token = newToken
            }
        }
    }

    func fetchMembers() {
        Task {
            do {
                let members = try await organizationStore.fetchMembers(organization.id)
                Task { @MainActor in
                    organizationStore.members = members
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.message
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OrganizationMembers(VOOrganization.Entity.devInstance)
            .navigationTitle(VOOrganization.Entity.devInstance.name)
            .environmentObject(AuthStore(VOToken.Value.devInstance))
            .environmentObject(OrganizationStore())
    }
}
