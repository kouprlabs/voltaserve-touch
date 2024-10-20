import SwiftUI
import VoltaserveCore

struct InvitationOutgoingList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var invitationStore = InvitationStore()
    @StateObject private var organizationStore = OrganizationStore()
    @State private var showCreate = false
    @State private var invitation: VOInvitation.Entity?
    private let organizationID: String

    init(_ organizationID: String) {
        self.organizationID = organizationID
    }

    var body: some View {
        VStack {
            if let entities = invitationStore.entities {
                Group {
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
                        }
                    }
                }
                .refreshable {
                    invitationStore.fetchNext(replace: true)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Invitations")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showCreate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                if invitationStore.isLoading, invitationStore.entities != nil {
                    ProgressView()
                }
            }
        }
        .sheet(isPresented: $showCreate) {
            InvitationCreate(organizationID)
        }
        .onAppear {
            invitationStore.organizationID = organizationID
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
        if invitationStore.isEntityThreshold(id) {
            invitationStore.fetchNext()
        }
    }
}
