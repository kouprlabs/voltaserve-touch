import Combine
import SwiftUI
import VoltaserveCore

struct GroupList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var groupStore: GroupStore
    @State private var showError = false
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
        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            groupStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { groupStore.query = $0 }
                .store(in: &cancellables)
            if authStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            groupStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
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

    func onAppearOrChange() {
        fetchList(replace: true)
        groupStore.startTimer()
    }

    func onListItemAppear(_ id: String) {
        if groupStore.isLast(id) {
            fetchList()
        }
    }

    func fetchList(replace: Bool = false) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !groupStore.hasNextPage() { return }
                let nextPage = groupStore.nextPage()
                let list = try await groupStore.fetchList(page: nextPage)
                Task { @MainActor in
                    groupStore.list = list
                    if let list {
                        if replace, nextPage == 1 {
                            groupStore.entities = list.data
                        } else {
                            groupStore.append(list.data)
                        }
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
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }
}
