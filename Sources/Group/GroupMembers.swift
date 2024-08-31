import SwiftUI
import Voltaserve

struct GroupMembers: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var groupStore: GroupStore
    @State private var showError = false
    @State private var errorMessage: String?
    private var id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            if let members = groupStore.members {
                List(members.data, id: \.id) { member in
                    VOUserRow(member)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .alert("Group Members Error", isPresented: $showError) {
            Button("Cancel") {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            if let token = authStore.token {
                groupStore.token = token
                fetchMembers()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                groupStore.token = newToken
            }
        }
    }

    func fetchMembers() {
        Task {
            do {
                let members = try await groupStore.fetchMembers(id)
                Task { @MainActor in
                    groupStore.members = members
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.message
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOMessages.unexpectedError
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupMembers("QvlPbDzXrlJM1")
            .navigationTitle("My Group")
            .environmentObject(AuthStore())
            .environmentObject(GroupStore())
    }
}
