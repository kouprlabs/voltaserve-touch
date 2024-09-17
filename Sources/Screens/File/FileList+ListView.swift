import SwiftUI
import VoltaserveCore

extension FileList {
    @ViewBuilder
    func listView(_ entities: [VOFile.Entity]) -> some View {
        List(selection: $fileStore.selection) {
            ForEach(entities, id: \.id) { file in
                if file.type == .file {
                    Button {
                        fileStore.tappedItem = file
                    } label: {
                        FileRow(file)
                            .fileActions(file)
                    }
                    .onAppear { onListItemAppear(file.id) }
                } else if file.type == .folder {
                    NavigationLink {
                        FileList(file.id)
                            .navigationTitle(file.name)
                    } label: {
                        FileRow(file)
                            .fileActions(file)
                    }
                    .onAppear { onListItemAppear(file.id) }
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
        .searchable(text: $fileStore.searchText)
        .onChange(of: fileStore.searchText) { fileStore.searchPublisher.send($1) }
        .refreshable { fileStore.fetchList(replace: true) }
        .navigationDestination(item: $fileStore.tappedItem) { FileViewer($0) }
    }
}
