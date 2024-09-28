import SwiftUI
import VoltaserveCore

struct UserSelector: View {
    @StateObject private var userStore = UserStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
    private let onCompletion: ((VOUser.Entity) -> Void)?
    private let groupID: String?
    private let organizationID: String?

    init(
        groupID: String? = nil,
        organizationID: String? = nil,
        onCompletion: ((VOUser.Entity) -> Void)? = nil
    ) {
        self.groupID = groupID
        self.organizationID = organizationID
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack {
            if let entities = userStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no users.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { user in
                                Button {
                                    dismiss()
                                    onCompletion?(user)
                                } label: {
                                    UserRow(user)
                                        .onAppear {
                                            onListItemAppear(user.id)
                                        }
                                }
                            }
                            if userStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .searchable(text: $userStore.searchText)
                .refreshable {
                    userStore.fetchList(replace: true)
                }
                .onChange(of: userStore.searchText) {
                    userStore.searchPublisher.send($1)
                }
                .voErrorAlert(
                    isPresented: $userStore.showError,
                    title: userStore.errorTitle,
                    message: userStore.errorMessage
                )
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Select User")
        .onAppear {
            if let token = tokenStore.token {
                userStore.token = token
                if let groupID {
                    userStore.groupID = groupID
                } else if let organizationID {
                    userStore.organizationID = organizationID
                }
                onAppearOrChange()
            }
        }
        .onDisappear {
            userStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                userStore.token = newToken
                onAppearOrChange()
            }
        }
        .onChange(of: userStore.query) {
            userStore.clear()
            userStore.fetchList()
        }
    }

    private func onAppearOrChange() {
        userStore.fetchList(replace: true)
        userStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if userStore.isLast(id) {
            userStore.fetchList()
        }
    }
}
