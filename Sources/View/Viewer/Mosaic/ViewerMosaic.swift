import Alamofire
import SwiftUI
import Voltaserve

struct ViewerMosaic: View {
    @EnvironmentObject private var state: ViewerMosaicState
    @State private var dragOffset = CGSize.zero
    @State private var lastDragOffset = CGSize.zero
    @State private var showZoomLevelMenu = false
    @State private var selectedZoomLevel: VOMosaic.ZoomLevel?

    init() {
        setupNavigationBarAppearance()
    }

    var body: some View {
        GeometryReader { geometry in
            let visibleRect = CGRect(
                origin: CGPoint(x: -dragOffset.width, y: -dragOffset.height),
                size: geometry.size
            )

            ZStack {
                if let zoomLevel = state.zoomLevel, !state.grid.isEmpty {
                    ForEach(0 ..< zoomLevel.rows, id: \.self) { row in
                        ForEach(0 ..< zoomLevel.cols, id: \.self) { col in
                            let size = state.sizeForCell(row: row, col: col)
                            let position = state.positionForCell(row: row, col: col)
                            let frame = state.frameForCellAt(position: position, size: size)

                            // Check if the cell is within the visible bounds or the surrounding buffer
                            if visibleRect.insetBy(
                                dx: -CGFloat(Constants.extraTilesToLoad) * size.width,
                                dy: -CGFloat(Constants.extraTilesToLoad) * size.height
                            ).intersects(frame) {
                                if let image = state.grid[row][col] {
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
                                            state.loadImageForCell(row: row, col: col)
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
                        state.unloadImagesOutsideRect(visibleRect, extraTilesToLoad: Constants.extraTilesToLoad)
                    }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let zoomLevels = state.zoomLevels {
                            ForEach(zoomLevels, id: \.index) { zoomLevel in
                                Button(action: {
                                    resetMosaicPosition()
                                    state.selectZoomLevel(zoomLevel)
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
                    try await state.loadMosaic()
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
