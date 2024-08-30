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
    private var id: String

    init(_ id: String) {
        self.id = id
    }

    var body: some View {
        NavigationStack {
            if let list = fileStore.list {
                List(list.data, id: \.id) { file in
                    NavigationLink {
                        if file.type == .file {
                            ViewerSelector(file)
                                .navigationTitle(file.name)
                        } else if file.type == .folder {
                            FileList(file.id)
                        }
                    } label: {
                        Text(file.name)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .listStyle(.inset)
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .alert("File List Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            if let token = authStore.token {
                fileStore.token = token
                viewerMosaicStore.token = token
                viewer3DStore.token = token
                viewerPDFStore.token = token
                fetchList()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let token = newToken {
                fileStore.token = token
                viewerMosaicStore.token = token
                viewer3DStore.token = token
                viewerPDFStore.token = token
                fetchList()
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
    FileList("x1novkR9M4YOe")
        .environmentObject(AuthStore())
        .environmentObject(FileStore())
        .environmentObject(Viewer3DStore())
        .environmentObject(ViewerPDFStore())
        .environmentObject(ViewerMosaicStore())
}
