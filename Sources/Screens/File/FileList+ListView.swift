import SwiftUI
import VoltaserveCore

extension FileList {
    @ViewBuilder
    func listView(_ entities: [VOFile.Entity]) -> some View {
        List(selection: $selection) {
            ForEach(entities, id: \.id) { file in
                if file.type == .file {
                    Button {
                        tappedItem = file
                    } label: {
                        FileRow(file)
                            .fileActions(file, list: self)
                    }
                    .onAppear { onListItemAppear(file.id) }
                } else if file.type == .folder {
                    NavigationLink {
                        FileList(file.id)
                            .navigationTitle(file.name)
                    } label: {
                        FileRow(file)
                            .fileActions(file, list: self)
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
            fetchList(replace: true)
        }
        .navigationDestination(item: $tappedItem) { FileViewer($0) }
    }
}
