import Combine
import SwiftUI
import Voltaserve

struct OrganizationList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            if let entities = organizationStore.entities {
                List {
                    ForEach(entities, id: \.id) { organization in
                        NavigationLink {
                            OrganizationMembers(organization)
                                .navigationTitle(organization.name)
                        } label: {
                            OrganizationRow(organization)
                                .onAppear { onListItemAppear(organization.id) }
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
                .navigationTitle("Organizations")
                .searchable(text: $searchText)
                .onChange(of: searchText) { searchPublisher.send($1) }
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
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { organizationStore.query = $0 }
                .store(in: &cancellables)
            if let token = authStore.token {
                onAppearOrChange(token)
            }
        }
        .onDisappear {
            organizationStore.stopRefreshTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                onAppearOrChange(newToken)
            }
        }
        .onChange(of: organizationStore.query) {
            organizationStore.entities = nil
            organizationStore.list = nil
            fetchList()
        }
    }

    func onAppearOrChange(_ token: VOToken.Value) {
        organizationStore.token = token
        organizationStore.clear()
        fetchList()
        organizationStore.startRefreshTimer()
    }

    func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList() {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                if !organizationStore.hasNextPage() { return }
                let list = try await organizationStore.fetchList(page: organizationStore.nextPage())
                Task { @MainActor in
                    organizationStore.list = list
                    if let list {
                        organizationStore.append(list.data)
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
    OrganizationList()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(OrganizationStore())
}
