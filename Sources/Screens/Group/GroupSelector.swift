import SwiftUI
import VoltaserveCore

struct GroupSelector: View {
    @StateObject private var groupStore = GroupStore()
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
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
                    }
                }
                .searchable(text: $groupStore.searchText)
                .refreshable {
                    groupStore.fetchList(replace: true)
                }
                .onChange(of: groupStore.searchText) {
                    groupStore.searchPublisher.send($1)
                }
                .voErrorAlert(
                    isPresented: $groupStore.showError,
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
            if let token = tokenStore.token {
                groupStore.token = token
                groupStore.organizationID = organizationID
                onAppearOrChange()
            }
        }
        .onDisappear {
            groupStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                groupStore.token = newToken
                onAppearOrChange()
            }
        }
        .onChange(of: groupStore.query) {
            groupStore.clear()
            groupStore.fetchList()
        }
    }

    private func onAppearOrChange() {
        groupStore.fetchList(replace: true)
        groupStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            groupStore.fetchList()
        }
    }
}
