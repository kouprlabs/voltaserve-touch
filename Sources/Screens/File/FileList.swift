import SwiftUI
import VoltaserveCore

struct FileList: View {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var selection = Set<String>()
    @State private var tappedItem: VOFile.Entity?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        if let entities = fileStore.entities {
            List(selection: $selection) {
                ForEach(entities, id: \.id) { file in
                    if file.type == .file {
                        Button {
                            if file.snapshot?.status == .ready {
                                tappedItem = file
                            }
                        } label: {
                            FileRow(file)
                                .fileActions(file, fileStore: fileStore)
                        }
                        .onAppear {
                            onListItemAppear(file.id)
                        }
                    } else if file.type == .folder {
                        NavigationLink {
                            FileOverview(file, workspaceStore: workspaceStore)
                                .navigationTitle(file.name)
                        } label: {
                            FileRow(file)
                                .fileActions(file, fileStore: fileStore)
                        }
                        .onAppear {
                            onListItemAppear(file.id)
                        }
                    }
                }
            }
            .listStyle(.inset)
            .navigationDestination(item: $tappedItem) {
                Viewer($0)
            }
            .sync($fileStore.selection, with: $selection)
        }
    }

    private func onListItemAppear(_ id: String) {
        if fileStore.isEntityThreshold(id) {
            fileStore.fetchNext()
        }
    }
}
