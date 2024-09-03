import SwiftUI
import Voltaserve

struct GroupMembers: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var membersStore: GroupMembersStore
    @EnvironmentObject var groupStore: GroupStore
    @State private var showAddMember = false
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage: String?
    private var group: VOGroup.Entity

    init(_ group: VOGroup.Entity) {
        self.group = group
    }

    var body: some View {
        VStack {
            if let list = membersStore.list {
                List(list.data, id: \.id) { member in
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
                        Button {
                            showAddMember = true
                        } label: {
                            Label("Add Member", systemImage: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    GroupSettings()
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
            groupStore.current = group
            if let token = authStore.token {
                membersStore.token = token
                groupStore.token = token
                fetchList()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                membersStore.token = newToken
                groupStore.token = newToken
            }
        }
    }

    func fetchList() {
        Task {
            do {
                let list = try await membersStore.fetchList(group.id)
                Task { @MainActor in
                    membersStore.list = list
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
        GroupMembers(VOGroup.Entity.devInstance)
            .navigationTitle(VOGroup.Entity.devInstance.name)
            .environmentObject(AuthStore(VOToken.Value.devInstance))
            .environmentObject(GroupMembersStore())
            .environmentObject(GroupStore())
    }
}
