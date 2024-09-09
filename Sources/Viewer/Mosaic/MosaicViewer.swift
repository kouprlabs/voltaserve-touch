import SwiftUI
import VoltaserveCore

struct MosaicViewer: View {
    @EnvironmentObject private var mosaicStore: MosaicStore
    @State private var dragOffset = CGSize.zero
    @State private var lastDragOffset = CGSize.zero
    @State private var showZoomLevelMenu = false
    @State private var selectedZoomLevel: VOMosaic.ZoomLevel?
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        if file.type == .file,
           let snapshot = file.snapshot,
           let download = snapshot.preview,
           let fileExtension = download.fileExtension, fileExtension.isImage(), snapshot.mosaic != nil {
            GeometryReader { geometry in
                let visibleRect = CGRect(
                    origin: CGPoint(x: -dragOffset.width, y: -dragOffset.height),
                    size: geometry.size
                )
                ZStack {
                    if let zoomLevel = mosaicStore.zoomLevel, !mosaicStore.grid.isEmpty {
                        ForEach(0 ..< zoomLevel.rows, id: \.self) { row in
                            ForEach(0 ..< zoomLevel.cols, id: \.self) { col in
                                let size = mosaicStore.sizeForCell(row: row, col: col)
                                let position = mosaicStore.positionForCell(row: row, col: col)
                                let frame = mosaicStore.frameForCellAt(position: position, size: size)

                                // Check if the cell is within the visible bounds or the surrounding buffer
                                if visibleRect.insetBy(
                                    dx: -CGFloat(Constants.extraTilesToLoad) * size.width,
                                    dy: -CGFloat(Constants.extraTilesToLoad) * size.height
                                ).intersects(frame) {
                                    if let image = mosaicStore.grid[row][col] {
                                        Image(uiImage: image)
                                            .resizable()
                                            .frame(width: size.width, height: size.height)
                                            .position(
                                                x: position.x + dragOffset.width,
                                                y: position.y + dragOffset.height
                                            )
                                    } else {
                                        Rectangle()
                                            .fill(Color.black)
                                            .frame(width: size.width, height: size.height)
                                            .position(
                                                x: position.x + dragOffset.width,
                                                y: position.y + dragOffset.height
                                            )
                                            .onAppear {
                                                mosaicStore.loadImageForCell(file.id, row: row, col: col)
                                            }
                                    }
                                }
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .clipped()
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = CGSize(
                                width: lastDragOffset.width + value.translation.width,
                                height: lastDragOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastDragOffset = dragOffset
                            mosaicStore.unloadImagesOutsideRect(
                                visibleRect,
                                extraTilesToLoad: Constants.extraTilesToLoad
                            )
                        }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            if let zoomLevels = mosaicStore.info?.metadata.zoomLevels {
                                ForEach(zoomLevels, id: \.index) { zoomLevel in
                                    Button(action: {
                                        resetMosaicPosition()
                                        mosaicStore.selectZoomLevel(zoomLevel)
                                    }, label: {
                                        Text("\(Int(zoomLevel.scaleDownPercentage))%")
                                    })
                                }
                            }
                        } label: {
                            Label("Zoom Levels", systemImage: "ellipsis.circle")
                        }
                    }
                }
                .onAppear {
                    Task {
                        try await mosaicStore.loadMosaic(file.id)
                    }
                }
            }
        }
    }

    private func resetMosaicPosition() {
        dragOffset = .zero
        lastDragOffset = .zero
    }

    private enum Constants {
        static let extraTilesToLoad = 1
    }
}
