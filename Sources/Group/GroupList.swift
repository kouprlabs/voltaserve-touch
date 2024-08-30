import SwiftUI
import Voltaserve

struct GroupList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            if let list = groupStore.list {
                List(list.data, id: \.id) { group in
                    NavigationLink {
                        GroupMembers()
                            .navigationTitle(group.name)
                    } label: {
                        GroupRow(group)
                    }
                }
                .navigationTitle("Groups")
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .alert("Group List Error", isPresented: $showError) {
            Button("Cancel") {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            fetchList()
        }
        .onAppear {
            if let token = authStore.token {
                groupStore.token = token
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                groupStore.token = newToken
            }
        }
    }

    func fetchList() {
        Task {
            do {
                let list = try await groupStore.fetchList()
                Task { @MainActor in
                    groupStore.list = list
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.userMessage
                }
            }
        }
    }
}

#Preview {
    GroupList()
        .environmentObject(AuthStore())
        .environmentObject(GroupStore())
}
