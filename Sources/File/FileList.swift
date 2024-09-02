import SwiftUI
import Voltaserve

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var viewerMosaicStore: ViewerMosaicStore
    @EnvironmentObject private var viewer3DStore: Viewer3DStore
    @EnvironmentObject private var viewerPDFStore: ViewerPDFStore
    @State private var showSettings = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var tappedItem: VOFile.Entity?
    private var id: String
    private var workspace: VOWorkspace.Entity

    init(_ id: String, workspace: VOWorkspace.Entity) {
        self.id = id
        self.workspace = workspace
    }

    var body: some View {
        VStack {
            if let list = fileStore.list {
                List(list.data, id: \.id) { file in
                    if file.type == .file {
                        Button {
                            tappedItem = file
                        } label: {
                            FileRow(file)
                        }
                    } else if file.type == .folder {
                        NavigationLink {
                            FileList(file.id, workspace: workspace)
                                .navigationTitle(file.name)
                        } label: {
                            FolderRow(file)
                        }
                    }
                }
                .listStyle(.inset)
                .navigationDestination(item: $tappedItem) { file in
                    ViewerSelector(file)
                }
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
                    WorkspaceSettings()
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            workspaceStore.current = workspace
            if let token = authStore.token {
                assignTokenToStores(token)
                fetchData()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                fetchData()
            }
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
        viewerMosaicStore.token = token
        viewer3DStore.token = token
        viewerPDFStore.token = token
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
            do {
                let list = try await fileStore.fetchList(id)
                Task { @MainActor in
                    fileStore.list = list
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
            workspace: VOWorkspace.Entity.devInstance
        )
        .navigationTitle(VOWorkspace.Entity.devInstance.name)
    }
    .environmentObject(AuthStore(VOToken.Value.devInstance))
    .environmentObject(FileStore())
    .environmentObject(WorkspaceStore())
    .environmentObject(Viewer3DStore())
    .environmentObject(ViewerPDFStore())
    .environmentObject(ViewerMosaicStore())
}
