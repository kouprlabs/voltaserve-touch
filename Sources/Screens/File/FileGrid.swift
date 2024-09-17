import SwiftUI
import VoltaserveCore

struct FileGrid: View {
    @EnvironmentObject private var fileStore: FileStore
    @State private var tappedItem: VOFile.Entity?

    var body: some View {
        if let entities = fileStore.entities {
            GeometryReader { geometry in
                let columns = Array(
                    repeating: GridItem(.fixed(FileMetrics.cellSize.width), spacing: VOMetrics.spacing),
                    count: Int(geometry.size.width / FileMetrics.cellSize.width)
                )
                ScrollView {
                    LazyVGrid(columns: columns, spacing: VOMetrics.spacing) {
                        ForEach(entities, id: \.id) { file in
                            if file.type == .file {
                                Button {
                                    tappedItem = file
                                } label: {
                                    FileCell(file)
                                        .fileActions(file)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear { onListItemAppear(file.id) }
                            } else if file.type == .folder {
                                NavigationLink {
                                    FileOverview(file.id)
                                        .navigationTitle(file.name)
                                } label: {
                                    FileCell(file)
                                        .fileActions(file)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear { onListItemAppear(file.id) }
                            }
                        }
                    }
                    .navigationDestination(item: $tappedItem) { FileViewer($0) }
                    .padding(.vertical, VOMetrics.spacing)
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
    }

    private func onListItemAppear(_ id: String) {
        if fileStore.isLast(id) {
            fileStore.fetchList()
        }
    }
}
