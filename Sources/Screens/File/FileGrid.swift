import SwiftUI
import VoltaserveCore

struct FileGrid: View {
    @ObservedObject private var fileStore: FileStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var tappedItem: VOFile.Entity?

    init(fileStore: FileStore, workspaceStore: WorkspaceStore) {
        self.fileStore = fileStore
        self.workspaceStore = workspaceStore
    }

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
                                    if file.snapshot?.status == .ready {
                                        tappedItem = file
                                    }
                                } label: {
                                    FileCell(file, fileStore: fileStore)
                                }
                                .buttonStyle(.plain)
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            } else if file.type == .folder {
                                NavigationLink {
                                    FileOverview(file, workspaceStore: workspaceStore)
                                        .navigationTitle(file.name)
                                } label: {
                                    FileCell(file, fileStore: fileStore)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .onAppear {
                                    onListItemAppear(file.id)
                                }
                            }
                        }
                    }
                    .navigationDestination(item: $tappedItem) {
                        Viewer($0)
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
