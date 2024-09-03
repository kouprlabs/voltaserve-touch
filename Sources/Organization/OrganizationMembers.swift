import SwiftUI
import Voltaserve

struct OrganizationMembers: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var membersStore: OrganizationMembersStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showAddMember = false
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var isLoading = false
    private let organization: VOOrganization.Entity

    init(_ organization: VOOrganization.Entity) {
        self.organization = organization
    }

    var body: some View {
        VStack {
            if let entities = membersStore.entities {
                List {
                    ForEach(entities, id: \.id) { member in
                        VOUserRow(member)
                            .onAppear { listItemAppears(member.id) }
                    }
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
                        Button {
                            showAddMember = true
                        } label: {
                            Label("Add Members", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    OrganizationSettings()
                }
                .sheet(isPresented: $showAddMember) {
                    Text("Add Member")
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
                membersStore.token = token
                organizationStore.token = token
                fetchList()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                membersStore.token = newToken
                organizationStore.token = newToken
            }
        }
    }

    func listItemAppears(_ id: String) {
        if membersStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !membersStore.hasNextPage() { return }
                let list = try await membersStore.fetchList(organization.id, page: membersStore.nextPage())
                Task { @MainActor in
                    membersStore.list = list
                    if let list {
                        membersStore.append(list.data)
                    }
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
            .environmentObject(OrganizationMembersStore())
            .environmentObject(OrganizationStore())
    }
}
