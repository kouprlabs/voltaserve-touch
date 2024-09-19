import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationMembers: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var membersStore: OrganizationMembersStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAddMember = false
    @State private var showSettings = false

    var body: some View {
        VStack {
            if let entities = membersStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { member in
                                VOUserRow(member)
                                    .onAppear {
                                        onListItemAppear(member.id)
                                    }
                            }
                        }
                    }
                }
                .searchable(text: $membersStore.searchText)
                .refreshable {
                    if let organization = organizationStore.current {
                        membersStore.fetchList(organization: organization, replace: true)
                    }
                }
                .onChange(of: membersStore.searchText) {
                    membersStore.searchPublisher.send($1)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showAddMember = true
                        } label: {
                            Label("Add Members", systemImage: "person.badge.plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    OrganizationSettings {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .sheet(isPresented: $showAddMember) {
                    Text("Add Member")
                }
                .voErrorAlert(
                    isPresented: $membersStore.showError,
                    title: membersStore.errorTitle,
                    message: membersStore.errorMessage
                )
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            membersStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: membersStore.query) {
            if let organization = organizationStore.current {
                membersStore.clear()
                membersStore.fetchList(organization: organization)
            }
        }
    }

    private func onAppearOrChange() {
        guard let organization = organizationStore.current else { return }
        membersStore.fetchList(organization: organization, replace: true)
        membersStore.startTimer(organization.id)
    }

    private func onListItemAppear(_ id: String) {
        if membersStore.isLast(id) {
            if let organization = organizationStore.current {
                membersStore.fetchList(organization: organization)
            }
        }
    }
}
