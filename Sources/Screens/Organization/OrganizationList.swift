import Combine
import SwiftUI
import VoltaserveCore

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
                            OrganizationOverview(organization)
                                .navigationBarTitleDisplayMode(.inline)
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
                .refreshable {
                    fetchList(replace: true)
                }
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
            organizationStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { organizationStore.query = $0 }
                .store(in: &cancellables)
            if authStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            organizationStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: organizationStore.query) {
            organizationStore.entities = nil
            organizationStore.list = nil
            fetchList()
        }
    }

    func onAppearOrChange() {
        fetchList(replace: true)
        organizationStore.startTimer()
    }

    func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList(replace: Bool = false) {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                if !organizationStore.hasNextPage() { return }
                let nextPage = organizationStore.nextPage()
                let list = try await organizationStore.fetchList(page: nextPage)
                Task { @MainActor in
                    organizationStore.list = list
                    if let list {
                        if replace, nextPage == 1 {
                            organizationStore.entities = list.data
                        } else {
                            organizationStore.append(list.data)
                        }
                    }
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    errorMessage = error.userMessage
                    showError = true
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }
}
