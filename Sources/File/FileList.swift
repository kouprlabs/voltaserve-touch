import Combine
import SwiftUI
import VoltaserveCore

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var mosaicStore: MosaicStore
    @EnvironmentObject private var glbStore: GLBStore
    @EnvironmentObject private var pdfStore: PDFStore
    @EnvironmentObject private var imageStore: ImageStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showSettings = false
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

    init(_ id: String, workspace: VOWorkspace.Entity, navigationTitle: String) {
        self.id = id
        self.workspace = workspace
        self.navigationTitle = navigationTitle
    }

    var body: some View {
        VStack {
            if let entities = fileStore.entities,
               let current = fileStore.current,
               let workspace = workspaceStore.current {
                List {
                    ForEach(entities, id: \.id) { file in
                        if file.type == .file {
                            Button {
                                tappedItem = file
                            } label: {
                                FileRow(file)
                            }
                            .onAppear {
                                onListItemAppear(file.id)
                            }
                        } else if file.type == .folder {
                            NavigationLink {
                                FileList(file.id, workspace: workspace, navigationTitle: file.name)
                            } label: {
                                FolderRow(file)
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
                .navigationTitle(getNavigationTitle(current: current, workspace: workspace))
                .searchable(text: $searchText)
                .onChange(of: searchText) { searchPublisher.send($1) }
                .refreshable {
                    fileStore.clear()
                    fetchList()
                }
                .navigationDestination(item: $tappedItem) { ViewerSelector($0) }
                .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                    Button(VOTextConstants.errorAlertButtonLabel) {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    WorkspaceSettings {
                        presentationMode.wrappedValue.dismiss()
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
                .sink { fileStore.query = .init(text: $0) }
                .store(in: &cancellables)
            workspaceStore.current = workspace
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
        mosaicStore.token = token
        glbStore.token = token
        pdfStore.token = token
        imageStore.token = token
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
    NavigationStack {
        FileList(
            VOWorkspace.Entity.devInstance.rootID,
            workspace: VOWorkspace.Entity.devInstance,
            navigationTitle: VOWorkspace.Entity.devInstance.name
        )
        .navigationTitle(VOWorkspace.Entity.devInstance.name)
    }
    .environmentObject(AuthStore(VOToken.Value.devInstance))
    .environmentObject(FileStore())
    .environmentObject(WorkspaceStore())
    .environmentObject(GLBStore())
    .environmentObject(PDFStore())
    .environmentObject(ImageStore())
    .environmentObject(MosaicStore())
}
