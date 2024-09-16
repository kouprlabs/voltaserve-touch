import SwiftUI
import VoltaserveCore

extension FileList {
    @ViewBuilder
    func gridView(_ entities: [VOFile.Entity]) -> some View {
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
                                    .fileActions(file, list: self)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear { onListItemAppear(file.id) }
                        } else if file.type == .folder {
                            NavigationLink {
                                FileList(file.id)
                                    .navigationTitle(file.name)
                            } label: {
                                FileCell(file)
                                    .fileActions(file, list: self)
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
    }
}
