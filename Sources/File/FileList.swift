import SwiftUI
import Voltaserve

struct FileList: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var fileStore: FileStore
    @EnvironmentObject private var viewerMosaicStore: ViewerMosaicStore
    @EnvironmentObject private var viewer3DStore: Viewer3DStore
    @EnvironmentObject private var viewerPDFStore: ViewerPDFStore
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var tappedItem: VOFile.Entity?
    private var id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        VStack {
            if let list = fileStore.list {
                List(list.data, id: \.id) { file in
                    if file.type == .file {
                        Button {
                            tappedItem = file
                        } label: {
                            Text(file.name)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    } else if file.type == .folder {
                        NavigationLink {
                            FileList(file.id)
                        } label: {
                            Text(file.name)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
                .listStyle(.inset)
                .navigationDestination(item: $tappedItem) { file in
                    ViewerSelector(file)
                }
                .alert("File List Error", isPresented: $showError) {
                    Button("OK") {}
                } message: {
                    Text(errorMessage)
                }

            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .onAppear {
            fetchList()
        }
        .onAppear {
            if let token = authStore.token {
                fileStore.token = token
                viewerMosaicStore.token = token
                viewer3DStore.token = token
                viewerPDFStore.token = token
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let token = newToken {
                fileStore.token = token
                viewerMosaicStore.token = token
                viewer3DStore.token = token
                viewerPDFStore.token = token
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
            }
        }
    }
}

#Preview {
    NavigationStack {
        FileList("x1novkR9M4YOe")
            .navigationTitle("My Workspace")
    }
    .environmentObject(AuthStore())
    .environmentObject(FileStore())
    .environmentObject(Viewer3DStore())
    .environmentObject(ViewerPDFStore())
    .environmentObject(ViewerMosaicStore())
}
