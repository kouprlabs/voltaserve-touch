import Alamofire
import SwiftUI

struct MosaicView: View {
    @ObservedObject var document: MosaicDocument

    @State private var dragOffset = CGSize.zero
    @State private var lastDragOffset = CGSize.zero
    @State private var showZoomLevelMenu = false
    @State private var selectedZoomLevel: MosaicStore.ZoomLevel?

    init(document: MosaicDocument) {
        self.document = document
        setupNavigationBarAppearance()
    }

    var body: some View {
        GeometryReader { geometry in
            let visibleRect = CGRect(
                origin: CGPoint(x: -dragOffset.width, y: -dragOffset.height),
                size: geometry.size
            )

            ZStack {
                if let zoomLevel = document.zoomLevel, !document.grid.isEmpty {
                    ForEach(0 ..< zoomLevel.rows, id: \.self) { row in
                        ForEach(0 ..< zoomLevel.cols, id: \.self) { col in
                            let size = document.sizeForCell(row: row, col: col)
                            let position = document.positionForCell(row: row, col: col)
                            let frame = document.frameForCellAt(position: position, size: size)

                            // Check if the cell is within the visible bounds or the surrounding buffer
                            if visibleRect.insetBy(
                                dx: -CGFloat(Constants.extraTilesToLoad) * size.width,
                                dy: -CGFloat(Constants.extraTilesToLoad) * size.height
                            ).intersects(frame) {
                                if let image = document.grid[row][col] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: size.width, height: size.height)
                                        .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
                                } else {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: size.width, height: size.height)
                                        .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
                                        .onAppear {
                                            document.loadImageForCell(row: row, col: col)
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
                        document.unloadImagesOutsideRect(visibleRect, extraTilesToLoad: Constants.extraTilesToLoad)
                    }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let zoomLevels = document.zoomLevels {
                            ForEach(zoomLevels, id: \.index) { zoomLevel in
                                Button(action: {
                                    resetMosaicPosition()
                                    document.selectZoomLevel(zoomLevel)
                                }, label: {
                                    Text("\(Int(zoomLevel.scaleDownPercentage))%")
                                })
                            }
                        }
                    } label: {
                        Label("Zoom Levels", systemImage: "ellipsis")
                    }
                }
            }
        }
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    private func resetMosaicPosition() {
        dragOffset = .zero
        lastDragOffset = .zero
    }

    private enum Constants {
        static let extraTilesToLoad = 1
    }
}
