import SwiftUI
import Voltaserve

struct GroupList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            if let entities = groupStore.entities {
                List {
                    ForEach(entities, id: \.id) { group in
                        NavigationLink {
                            GroupMembers(group)
                                .navigationTitle(group.name)
                        } label: {
                            GroupRow(group)
                                .onAppear { onListItemAppear(group.id) }
                        }
                    }
                    if isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }
                .searchable(text: $searchText)
                .navigationTitle("Groups")
            } else {
                ProgressView()
            }
        }
        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            if let token = authStore.token {
                onAppearOrChange(token)
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                onAppearOrChange(newToken)
            }
        }
    }

    func onAppearOrChange(_ token: VOToken.Value) {
        groupStore.token = token
        groupStore.clear()
        fetchList()
    }

    func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !groupStore.hasNextPage() { return }
                let list = try await groupStore.fetchList(page: groupStore.nextPage())
                Task { @MainActor in
                    groupStore.list = list
                    if let list {
                        groupStore.append(list.data)
                    }
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.userMessage
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    GroupList()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(GroupStore())
}
