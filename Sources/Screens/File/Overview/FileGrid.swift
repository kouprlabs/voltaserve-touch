import SwiftUI
import VoltaserveCore

struct FileGrid: View {
    @EnvironmentObject private var fileStore: FileStore
    @State private var tappedItem: VOFile.Entity?

    var body: some View {
        if let entities = fileStore.entities {
            GeometryReader { geometry in
                let columns = Array(
                    repeating: GridItem(.fixed(FileCellMetrics.cellSize.width), spacing: VOMetrics.spacing),
                    count: Int(geometry.size.width / FileCellMetrics.cellSize.width) +
                        (UIDevice.current.userInterfaceIdiom == .pad ? -1 : 0)
                )
                ScrollView {
                    LazyVGrid(columns: columns, spacing: VOMetrics.spacing) {
                        ForEach(entities, id: \.id) { file in
                            if file.type == .file {
                                Button {
                                    tappedItem = file
                                } label: {
                                    FileCell(file)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            } else if file.type == .folder {
                                NavigationLink {
                                    FileOverview(file.id)
                                        .navigationTitle(file.name)
                                } label: {
                                    FileCell(file)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            }
                        }
                    }
                    .navigationDestination(item: $tappedItem) {
                        FileViewer($0)
                    }
                    .modifierIfPhone {
                        $0.padding(.vertical, VOMetrics.spacing)
                    }
                }
            }
            .modifierIfPad {
                $0.edgesIgnoringSafeArea(.bottom)
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
