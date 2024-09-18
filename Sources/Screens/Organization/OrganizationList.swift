import Combine
import SwiftUI
import VoltaserveCore

struct OrganizationList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @State private var showError = false
    @State private var errorTitle: String?
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
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .onAppear {
            organizationStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink {
                    organizationStore.query = $0
                }
                .store(in: &cancellables)
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            organizationStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
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

    private func onAppearOrChange() {
        fetchList(replace: true)
        organizationStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if organizationStore.isLast(id) {
            fetchList()
        }
    }

    private func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOOrganization.List?

        VOErrorResponse.withErrorHandling {
            if !organizationStore.hasNextPage() { return false }
            nextPage = organizationStore.nextPage()
            list = try await organizationStore.fetchList(page: nextPage)
            return true
        } success: {
            organizationStore.list = list
            if let list {
                if replace, nextPage == 1 {
                    organizationStore.entities = list.data
                } else {
                    organizationStore.append(list.data)
                }
            }
        } failure: { message in
            errorTitle = "Error: Fetching Organizations"
            errorMessage = message
            showError = true
        } anyways: {
            isLoading = false
        }
    }
}
