import Combine
import SwiftUI
import VoltaserveCore

struct BrowserList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var browserStore: BrowserStore
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var tappedItem: VOFile.Entity?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    private let id: String
    private let workspace: VOWorkspace.Entity
    private let navigationTitle: String
    private let onDismiss: (() -> Void)?

    init(
        _ id: String,
        workspace: VOWorkspace.Entity,
        navigationTitle: String,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
        self.workspace = workspace
        self.navigationTitle = navigationTitle
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack {
            if let entities = browserStore.entities,
               let current = browserStore.current {
                VStack {
                    if entities.count == 0 {
                        Text("There are no items.")
                    } else {
                        List {
                            ForEach(entities, id: \.id) { file in
                                NavigationLink {
                                    BrowserList(
                                        file.id,
                                        workspace: workspace,
                                        navigationTitle: file.name,
                                        onDismiss: onDismiss
                                    )
                                } label: {
                                    FolderRow(file)
                                }
                                .onAppear { onListItemAppear(file.id) }
                            }
                            if isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.inset)
                        .searchable(text: $searchText)
                        .onChange(of: searchText) { searchPublisher.send($1) }
                        .refreshable {
                            browserStore.clear()
                            fetchList()
                        }
                        .navigationDestination(item: $tappedItem) { FileViewer($0) }
                        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                            Button(VOTextConstants.errorAlertButtonLabel) {}
                        } message: {
                            if let errorMessage {
                                Text(errorMessage)
                            }
                        }
                    }
                }
                .navigationTitle(getNavigationTitle(current: current, workspace: workspace))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { onDismiss?() }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { browserStore.query = .init(text: $0) }
                .store(in: &cancellables)
            if let token = authStore.token {
                onAppearOrChange(token)
            }
        }
        .onDisappear {
            browserStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                onAppearOrChange(newToken)
            }
        }
        .onChange(of: browserStore.query) {
            browserStore.entities = nil
            browserStore.list = nil
            fetchList()
        }
    }

    func getNavigationTitle(current: VOFile.Entity, workspace: VOWorkspace.Entity) -> String {
        if current.id == id {
            if current.parentID == nil {
                workspace.name
            } else {
                current.name
            }
        } else {
            navigationTitle
        }
    }

    func onAppearOrChange(_ token: VOToken.Value) {
        assignTokenToStores(token)
        browserStore.clear()
        fetchData()
        browserStore.startTimer()
    }

    func onListItemAppear(_ id: String) {
        if browserStore.isLast(id) {
            fetchList()
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        browserStore.token = token
    }

    func fetchData() {
        fetchFile()
        fetchList()
    }

    func fetchFile() {
        Task {
            do {
                let file = try await browserStore.fetch(id)
                Task { @MainActor in
                    browserStore.current = file
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    errorMessage = error.userMessage
                    showError = true
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

    func fetchList() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                if !browserStore.hasNextPage() { return }
                let list = try await browserStore.fetchList(id, page: browserStore.nextPage())
                Task { @MainActor in
                    browserStore.list = list
                    if let list {
                        browserStore.append(list.data)
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
                    showError = true
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BrowserList(
            VOWorkspace.Entity.devInstance.rootID,
            workspace: VOWorkspace.Entity.devInstance,
            navigationTitle: VOWorkspace.Entity.devInstance.name
        )
        .navigationTitle(VOWorkspace.Entity.devInstance.name)
    }
    .environmentObject(AuthStore(VOToken.Value.devInstance))
    .environmentObject(BrowserStore())
}
