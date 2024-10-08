import SwiftUI
import VoltaserveCore

struct InvitationOutgoingList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @StateObject private var organizationStore = OrganizationStore()
    @State private var invitation: VOInvitation.Entity?

    var body: some View {
        Group {
            if let entities = invitationStore.entities {
                if entities.isEmpty {
                    Text("There are no invitations.")
                } else {
                    List {
                        ForEach(entities, id: \.id) { invitation in
                            NavigationLink {
                                InvitationOverview(
                                    invitation,
                                    invitationStore: invitationStore,
                                    isDeletable: true
                                )
                            } label: {
                                InvitationOutgoingRow(invitation)
                                    .onAppear {
                                        onListItemAppear(invitation.id)
                                    }
                            }
                        }
                        if invitationStore.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Invitations")
        .onAppear {
            if let organization = organizationStore.current {
                invitationStore.organizationID = organization.id
            }
            if let token = tokenStore.token {
                assignTokenToStores(token)
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                startTimers()
                onAppearOrChange()
            }
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        invitationStore.fetchList(replace: true)
    }

    private func startTimers() {
        invitationStore.startTimer()
        organizationStore.startTimer()
    }

    private func stopTimers() {
        invitationStore.stopTimer()
        organizationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        invitationStore.token = token
        organizationStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if invitationStore.isLast(id) {
            invitationStore.fetchList()
        }
    }
}
