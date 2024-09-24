import SwiftUI
import VoltaserveCore

struct InvitationListOutgoing: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @StateObject private var invitationStore = InvitationStore()
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
                                InvitationInfo(invitation, isDeletable: true)
                            } label: {
                                InvitationRowOutgoing(invitation)
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
            if let token = tokenStore.token {
                invitationStore.token = token
                if let organization = organizationStore.current {
                    invitationStore.organizationID = organization.id
                }
                onAppearOrChange()
            }
        }
        .onDisappear {
            invitationStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                invitationStore.token = newToken
                onAppearOrChange()
            }
        }
    }

    private func onAppearOrChange() {
        invitationStore.fetchList(replace: true)
        invitationStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if invitationStore.isLast(id) {
            invitationStore.fetchList()
        }
    }
}
