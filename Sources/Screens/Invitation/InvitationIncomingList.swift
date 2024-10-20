import SwiftUI
import VoltaserveCore

struct InvitationIncomingList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @State private var showInfo = false
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
                                    isAcceptableDeclinable: true
                                )
                            } label: {
                                InvitationIncomingRow(invitation)
                                    .onAppear {
                                        onListItemAppear(invitation.id)
                                    }
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
                assignTokenToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                onAppearOrChange()
            }
        }
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        invitationStore.fetchNext(replace: true)
    }

    private func startTimers() {
        invitationStore.startTimer()
    }

    private func stopTimers() {
        invitationStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        invitationStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if invitationStore.isEntityThreshold(id) {
            invitationStore.fetchNext()
        }
    }
}
