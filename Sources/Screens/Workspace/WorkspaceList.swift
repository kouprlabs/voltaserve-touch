import Combine
import SwiftUI
import VoltaserveCore

struct WorkspaceList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var accountStore: AccountStore
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var showAccount = false
    @State private var selection: String?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            if let entities = workspaceStore.entities {
                List {
                    ForEach(entities, id: \.id) { workspace in
                        NavigationLink {
                            WorkspaceOverview(workspace)
                                .navigationBarTitleDisplayMode(.inline)
                                .navigationTitle(workspace.name)
                        } label: {
                            WorkspaceRow(workspace)
                                .onAppear { onListItemAppear(workspace.id) }
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
                .searchable(text: $searchText)
                .onChange(of: searchText) { searchPublisher.send($1) }
                .refreshable {
                    fetchList(replace: true)
                }
                .navigationTitle("Home")
                .toolbar {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        accountButton
                            .padding(.trailing, VOMetrics.spacingXs)
                    } else {
                        accountButton
                    }
                }
                .sheet(isPresented: $showAccount) {
                    AccountSettings()
                }
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        .onAppear {
            workspaceStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink {
                    workspaceStore.query = $0
                }
                .store(in: &cancellables)
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            workspaceStore.stopTimer()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
        .onChange(of: workspaceStore.query) {
            workspaceStore.entities = nil
            workspaceStore.list = nil
            fetchList()
        }
    }

    var accountButton: some View {
        Button {
            showAccount.toggle()
        } label: {
            if let user = accountStore.identityUser, let picture = user.picture {
                VOAvatar(name: user.fullName, size: 30, base64Image: picture)
                    .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
            } else {
                Label("Account", systemImage: "person.crop.circle")
            }
        }
    }

    private func onAppearOrChange() {
        fetchList(replace: true)
        fetchUser()
        workspaceStore.startTimer()
    }

    private func onListItemAppear(_ id: String) {
        if workspaceStore.isLast(id) {
            fetchList()
        }
    }

    private func fetchList(replace: Bool = false) {
        if isLoading { return }
        isLoading = true

        var nextPage = -1
        var list: VOWorkspace.List?

        VOErrorResponse.withErrorHandling {
            if !workspaceStore.hasNextPage() { return false }
            nextPage = workspaceStore.nextPage()
            list = try await workspaceStore.fetchList(page: nextPage)
            return true
        } success: {
            workspaceStore.list = list
            if let list {
                if replace, nextPage == 1 {
                    workspaceStore.entities = list.data
                } else {
                    workspaceStore.append(list.data)
                }
            }
        } failure: { message in
            errorTitle = "Error: Fetching Workspaces"
            errorMessage = message
            showError = true
        } anyways: {
            isLoading = false
        }
    }

    private func fetchUser() {
        var user: VOIdentityUser.Entity?

        VOErrorResponse.withErrorHandling {
            user = try await accountStore.fetchUser()
            return true
        } success: {
            accountStore.identityUser = user
        } failure: { message in
            errorTitle = "Error: Fetching User"
            errorMessage = message
            showError = true
        }
    }
}
