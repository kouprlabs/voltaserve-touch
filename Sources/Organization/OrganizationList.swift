import SwiftUI
import Voltaserve

struct OrganizationList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            if let list = organizationStore.list {
                List(list.data, id: \.id) { organization in
                    NavigationLink {
                        OrganizationMembers()
                            .navigationTitle(organization.name)
                    } label: {
                        OrganizationRow(organization)
                    }
                }
                .navigationTitle("Organizations")
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .alert("Organization List Error", isPresented: $showError) {
            Button("Cancel") {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            if let token = authStore.token {
                organizationStore.token = token
                fetchList()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                organizationStore.token = newToken
            }
        }
    }

    func fetchList() {
        Task {
            do {
                let list = try await organizationStore.fetchList()
                Task { @MainActor in
                    organizationStore.list = list
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.userMessage
                }
            } catch {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.localizedDescription
                }
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    OrganizationList()
        .environmentObject(AuthStore())
        .environmentObject(OrganizationStore())
}
