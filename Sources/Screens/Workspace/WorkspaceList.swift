import Combine
import SwiftUI
import VoltaserveCore

struct WorkspaceList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var accountStore: AccountStore
    @State private var showError = false
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
        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            workspaceStore.clear()
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { workspaceStore.query = $0 }
                .store(in: &cancellables)
            if authStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            workspaceStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
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
            if let user = accountStore.user, let picture = user.picture {
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
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !workspaceStore.hasNextPage() { return }
                let nextPage = workspaceStore.nextPage()
                let list = try await workspaceStore.fetchList(page: nextPage)
                Task { @MainActor in
                    workspaceStore.list = list
                    if let list {
                        if replace, nextPage == 1 {
                            workspaceStore.entities = list.data
                        } else {
                            workspaceStore.append(list.data)
                        }
                    }
                }
            } catch let error as VOErrorResponse {
                showError = true
                errorMessage = error.message
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }

    private func fetchUser() {
        Task {
            do {
                let user = try await accountStore.fetchUser()
                Task { @MainActor in
                    accountStore.user = user
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
