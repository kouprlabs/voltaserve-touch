import Alamofire
import SwiftUI

struct ViewerMosaic: View {
    @EnvironmentObject private var vm: ViewerMosaicViewModel
    @State private var dragOffset = CGSize.zero
    @State private var lastDragOffset = CGSize.zero
    @State private var showZoomLevelMenu = false
    @State private var selectedZoomLevel: ViewerMosaicStore.ZoomLevel?

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
                if let zoomLevel = vm.zoomLevel, !vm.grid.isEmpty {
                    ForEach(0 ..< zoomLevel.rows, id: \.self) { row in
                        ForEach(0 ..< zoomLevel.cols, id: \.self) { col in
                            let size = vm.sizeForCell(row: row, col: col)
                            let position = vm.positionForCell(row: row, col: col)
                            let frame = vm.frameForCellAt(position: position, size: size)

                            // Check if the cell is within the visible bounds or the surrounding buffer
                            if visibleRect.insetBy(
                                dx: -CGFloat(Constants.extraTilesToLoad) * size.width,
                                dy: -CGFloat(Constants.extraTilesToLoad) * size.height
                            ).intersects(frame) {
                                if let image = vm.grid[row][col] {
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
                                            vm.loadImageForCell(row: row, col: col)
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
                        vm.unloadImagesOutsideRect(visibleRect, extraTilesToLoad: Constants.extraTilesToLoad)
                    }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if let zoomLevels = vm.zoomLevels {
                            ForEach(zoomLevels, id: \.index) { zoomLevel in
                                Button(action: {
                                    resetMosaicPosition()
                                    vm.selectZoomLevel(zoomLevel)
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
                vm.loadMosaic()
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
