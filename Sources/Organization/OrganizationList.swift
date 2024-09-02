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
                        OrganizationMembers(organization)
                            .navigationTitle(organization.name)
                    } label: {
                        OrganizationRow(organization)
                    }
                }
                .navigationTitle("Organizations")
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
    OrganizationList()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(OrganizationStore())
}
