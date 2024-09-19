import SwiftUI
import VoltaserveCore

struct FileList: View {
    @EnvironmentObject private var fileStore: FileStore
    @State private var tappedItem: VOFile.Entity?

    var body: some View {
        if let entities = fileStore.entities {
            List(selection: $fileStore.selection) {
                ForEach(entities, id: \.id) { file in
                    if file.type == .file {
                        Button {
                            tappedItem = file
                        } label: {
                            FileRow(file)
                                .fileActions(file)
                        }
                        .onAppear {
                            onListItemAppear(file.id)
                        }
                    } else if file.type == .folder {
                        NavigationLink {
                            FileOverview(file.id)
                                .navigationTitle(file.name)
                        } label: {
                            FileRow(file)
                                .fileActions(file)
                        }
                        .onAppear {
                            onListItemAppear(file.id)
                        }
                    }
                }
                if fileStore.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .listStyle(.inset)
            .navigationDestination(item: $tappedItem) {
                FileViewer($0)
            }
        }
    }

    private func onListItemAppear(_ id: String) {
        if fileStore.isLast(id) {
            fileStore.fetchList()
        }
    }
}
