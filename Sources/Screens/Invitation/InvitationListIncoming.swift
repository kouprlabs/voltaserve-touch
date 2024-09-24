import SwiftUI
import VoltaserveCore

struct InvitationListIncoming: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var invitationStore: InvitationStore
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
                                InvitationInfo(invitation, isAcceptableDeclinable: true)
                            } label: {
                                InvitationRowIncoming(invitation)
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
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            invitationStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
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
