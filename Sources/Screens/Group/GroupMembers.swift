import Combine
import SwiftUI
import VoltaserveCore

struct GroupMembers: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var membersStore: GroupMembersStore
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showAddMember = false
    @State private var showSettings = false

    var body: some View {
        VStack {
            if let entities = membersStore.entities {
                List {
                    ForEach(entities, id: \.id) { member in
                        VOUserRow(member)
                            .onAppear {
                                onListItemAppear(member.id)
                            }
                    }
                    if membersStore.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .searchable(text: $membersStore.searchText)
                .refreshable {
                    if let group = groupStore.current {
                        membersStore.fetchList(group: group, replace: true)
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
                            Label("Add Member", systemImage: "person.badge.plus")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    GroupSettings {
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
            membersStore.clear()
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
            if let group = groupStore.current {
                membersStore.fetchList(group: group, replace: true)
            }
        }
    }

    private func onAppearOrChange() {
        guard let group = groupStore.current else { return }
        membersStore.fetchList(group: group, replace: true)
        membersStore.startTimer(group.id)
    }

    private func onListItemAppear(_ id: String) {
        if membersStore.isLast(id) {
            if let group = groupStore.current {
                membersStore.fetchList(group: group)
            }
        }
    }
}
