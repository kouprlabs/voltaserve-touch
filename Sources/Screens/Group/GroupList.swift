import Combine
import SwiftUI
import VoltaserveCore

struct GroupList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            if let entities = groupStore.entities {
                List {
                    ForEach(entities, id: \.id) { group in
                        NavigationLink {
                            GroupOverview(group)
                                .navigationBarTitleDisplayMode(.inline)
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
                .navigationTitle("Groups")
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
            groupStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { groupStore.query = $0 }
                .store(in: &cancellables)
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            groupStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: groupStore.query) {
            groupStore.entities = nil
            groupStore.list = nil
            fetchList()
        }
    }

    private func onAppearOrChange() {
        fetchList(replace: true)
        groupStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            fetchList()
        }
    }

    private func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOGroup.List?

        VOErrorResponse.withErrorHandling {
            if !groupStore.hasNextPage() { return }
            nextPage = groupStore.nextPage()
            list = try await groupStore.fetchList(page: nextPage)
        } success: {
            groupStore.list = list
            if let list {
                if replace, nextPage == 1 {
                    groupStore.entities = list.data
                } else {
                    groupStore.append(list.data)
                }
            }
        } failure: { message in
            errorTitle = "Error: Fetching Groups"
            errorMessage = message
            showError = true
        } anyways: {
            isLoading = false
        }
    }
}
