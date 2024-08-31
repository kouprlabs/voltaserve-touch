import SwiftUI
import Voltaserve

struct OrganizationMembers: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showError = false
    @State private var errorMessage: String?
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            if let members = organizationStore.members {
                List(members.data, id: \.id) { member in
                    VOUserRow(member)
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .alert("Organization Members Error", isPresented: $showError) {
            Button("Cancel") {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            if let token = authStore.token {
                organizationStore.token = token
                fetchMembers()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                organizationStore.token = newToken
            }
        }
    }

    func fetchMembers() {
        Task {
            do {
                let members = try await organizationStore.fetchMembers(id)
                Task { @MainActor in
                    organizationStore.members = members
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
        OrganizationMembers("aKQxy35RBP3p3")
            .navigationTitle("My Organization")
            .environmentObject(AuthStore())
            .environmentObject(OrganizationStore())
    }
}
