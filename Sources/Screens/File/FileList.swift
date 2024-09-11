import Combine
import SwiftUI
import VoltaserveCore

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.editMode) private var editMode
    @State private var selection = Set<String>()
    @State private var showMove = false
    @State private var showCopy = false
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var tappedItem: VOFile.Entity?
    @State private var searchText = ""
    @State private var searchPublisher = PassthroughSubject<String, Never>()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isLoading = false
    @State private var isMoving = false
    private let id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            if let entities = fileStore.entities,
               let workspace = workspaceStore.current {
                if entities.count == 0 {
                    Text("There are no items.")
                } else {
                    List(selection: $selection) {
                        ForEach(entities, id: \.id) { file in
                            if file.type == .file {
                                Button {
                                    tappedItem = file
                                } label: {
                                    FileRow(file)
                                        .fileContextMenu(
                                            file,
                                            selection: $selection,
                                            onMove: { showMove = true },
                                            onCopy: { showCopy = true }
                                        )
                                }
                                .onAppear { onListItemAppear(file.id) }
                            } else if file.type == .folder {
                                NavigationLink {
                                    FileList(file.id)
                                        .navigationTitle(file.name)
                                } label: {
                                    FolderRow(file)
                                        .fileContextMenu(
                                            file,
                                            selection: $selection,
                                            onMove: { showMove = true },
                                            onCopy: { showCopy = true }
                                        )
                                }
                                .onAppear { onListItemAppear(file.id) }
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
                    .listStyle(.inset)
                    .searchable(text: $searchText)
                    .onChange(of: searchText) { searchPublisher.send($1) }
                    .refreshable {
                        fileStore.clear()
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
                    .sheet(isPresented: $showSettings) {
                        WorkspaceSettings {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .sheet(isPresented: $showMove) {
                        FileMove(
                            workspace: workspace,
                            selection: selection,
                            isProcessing: $isMoving,
                            isVisible: $showMove
                        )
                    }
                }
            } else {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            if editMode?.wrappedValue.isEditing == true, selection.count > 0 {
                ToolbarItem(placement: .bottomBar) {
                    FileMenu(
                        selection,
                        onMove: { showMove = true },
                        onCopy: { showCopy = true }
                    )
                }
            }
        }
        .onAppear {
            searchPublisher
                .debounce(for: .seconds(1), scheduler: RunLoop.main)
                .removeDuplicates()
                .sink { fileStore.query = .init(text: $0) }
                .store(in: &cancellables)
            if let token = authStore.token {
                onAppearOrChange(token)
            }
        }
        .onDisappear {
            fileStore.stopTimer()
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                onAppearOrChange(newToken)
            }
        }
        .onChange(of: fileStore.query) {
            fileStore.entities = nil
            fileStore.list = nil
            fetchList()
        }
    }

    func onAppearOrChange(_ token: VOToken.Value) {
        assignTokenToStores(token)
        fileStore.clear()
        fetchData()
        fileStore.startTimer()
    }

    func onListItemAppear(_ id: String) {
        if fileStore.isLast(id) {
            fetchList()
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }

    func fetchData() {
        fetchFile()
        fetchList()
    }

    func fetchFile() {
        Task {
            do {
                let file = try await fileStore.fetch(id)
                Task { @MainActor in
                    fileStore.current = file
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
                if !fileStore.hasNextPage() { return }
                let list = try await fileStore.fetchList(id, page: fileStore.nextPage())
                Task { @MainActor in
                    fileStore.list = list
                    if let list {
                        fileStore.append(list.data)
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
    FileList(VOWorkspace.Entity.devInstance.rootID)
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(FileStore())
        .environmentObject(WorkspaceStore(VOWorkspace.Entity.devInstance))
}
