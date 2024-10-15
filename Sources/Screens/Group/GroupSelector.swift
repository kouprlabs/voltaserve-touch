import SwiftUI
import VoltaserveCore

struct GroupSelector: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var groupStore = GroupStore()
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var searchText = ""
    private let onCompletion: ((VOGroup.Entity) -> Void)?
    private let organizationID: String?

    init(
        organizationID: String?,
        onCompletion: ((VOGroup.Entity) -> Void)? = nil
    ) {
        self.organizationID = organizationID
        self.onCompletion = onCompletion
    }

    var body: some View {
        VStack {
            if let entities = groupStore.entities {
                Group {
                    if entities.count == 0 {
                        Text("There are no groups.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { group in
                                Button {
                                    dismiss()
                                    onCompletion?(group)
                                } label: {
                                    GroupRow(group)
                                        .onAppear {
                                            onListItemAppear(group.id)
                                        }
                                }
                            }
                            if groupStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .searchable(text: $searchText)
                        .onChange(of: groupStore.searchText) {
                            groupStore.searchPublisher.send($1)
                        }
                    }
                }
                .refreshable {
                    groupStore.fetchList(replace: true)
                }
                .voErrorAlert(
                    isPresented: $showError,
                    title: groupStore.errorTitle,
                    message: groupStore.errorMessage
                )
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Select Group")
        .onAppear {
            groupStore.organizationID = organizationID
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
        .onChange(of: groupStore.query) {
            groupStore.clear()
            groupStore.fetchList()
        }
        .sync($groupStore.showError, with: $showError)
        .sync($groupStore.searchText, with: $searchText)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            groupStore.fetchList()
        }
    }

    private func fetchData() {
        groupStore.fetchList(replace: true)
    }

    private func startTimers() {
        groupStore.startTimer()
    }

    private func stopTimers() {
        groupStore.stopTimer()
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        groupStore.token = token
    }
}
