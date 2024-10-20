import SwiftUI
import VoltaserveCore

struct UserSelector: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var userStore = UserStore()
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var showError = false
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
                        }
                        .searchable(text: $searchText)
                        .onChange(of: userStore.searchText) {
                            userStore.searchPublisher.send($1)
                        }
                    }
                }
                .refreshable {
                    userStore.fetchNext(replace: true)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if userStore.isLoading, userStore.entities != nil {
                            ProgressView()
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Select User")
        .voErrorAlert(
            isPresented: $showError,
            title: userStore.errorTitle,
            message: userStore.errorMessage
        )
        .onAppear {
            if let groupID {
                userStore.groupID = groupID
            } else if let organizationID {
                userStore.organizationID = organizationID
            }
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
        .onChange(of: userStore.query) {
            userStore.clear()
            userStore.fetchNext()
        }
        .sync($userStore.searchText, with: $searchText)
        .sync($userStore.showError, with: $showError)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        userStore.fetchNext(replace: true)
    }

    private func startTimers() {
        userStore.startTimer()
    }

    private func stopTimers() {
        userStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }

    private func onListItemAppear(_ id: String) {
        if userStore.isEntityThreshold(id) {
            userStore.fetchNext()
        }
    }
}
