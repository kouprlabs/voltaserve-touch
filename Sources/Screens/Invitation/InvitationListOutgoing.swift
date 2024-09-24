import SwiftUI
import VoltaserveCore

struct InvitationListOutgoing: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var invitationStore: InvitationStore

    var body: some View {
        Group {
            if let entities = invitationStore.entities {
                if entities.isEmpty {
                    Text("There are no invitations.")
                } else {
                    List {
                        ForEach(entities, id: \.id) { invitation in
                            InvitationOutgoingRow(invitation)
                                .onAppear {
                                    onListItemAppear(invitation.id)
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
        .onAppear {
            if let token = tokenStore.token {
                invitationStore.token = token
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
