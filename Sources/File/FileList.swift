import SwiftUI
import Voltaserve

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @EnvironmentObject private var viewerMosaicStore: ViewerMosaicStore
    @EnvironmentObject private var viewer3DStore: Viewer3DStore
    @EnvironmentObject private var viewerPDFStore: ViewerPDFStore
    @State private var showWorkspaceSettings = false
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
                .alert(VOMessages.errorTitle, isPresented: $showError) {
                    Button("OK") {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showWorkspaceSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showWorkspaceSettings) {
                    WorkspaceSettings()
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            if let token = authStore.token {
                assignTokenToStores(token)

                workspaceStore.current = workspace

                fetchFile()
                fetchList()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
        viewerMosaicStore.token = token
        viewer3DStore.token = token
        viewerPDFStore.token = token
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
                    errorMessage = VOMessages.unexpectedError
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
                    errorMessage = VOMessages.unexpectedError
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FileList(
            "x1novkR9M4YOe",
            workspace: .init(
                id: UUID().uuidString,
                name: "My Workspace",
                permission: .owner,
                storageCapacity: 100_000_000_000,
                rootID: UUID().uuidString,
                organization: .init(
                    id: UUID().uuidString,
                    name: "My Organization",
                    permission: .owner,
                    createTime: Date().ISO8601Format()
                ),
                createTime: Date().ISO8601Format()
            )
        )
        .navigationTitle("My Workspace")
    }
    .environmentObject(AuthStore())
    .environmentObject(FileStore())
    .environmentObject(WorkspaceStore())
    .environmentObject(Viewer3DStore())
    .environmentObject(ViewerPDFStore())
    .environmentObject(ViewerMosaicStore())
}
