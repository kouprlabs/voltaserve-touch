import SwiftUI
import UIKit
import Combine
import Alamofire

struct MosaicView: View {
    @ObservedObject var viewModel: MosaicViewModel
    @State private var dragOffset = CGSize.zero
    @State private var lastDragOffset = CGSize.zero

    var body: some View {
        GeometryReader { geometry in
            let visibleRect = CGRect(
                origin: CGPoint(x: -dragOffset.width, y: -dragOffset.height),
                size: geometry.size
            )

            ZStack {
                if viewModel.gridLoaded, viewModel.image != nil {
                    ForEach(0 ..< viewModel.image!.rows, id: \.self) { row in
                        ForEach(0 ..< viewModel.image!.cols, id: \.self) { col in
                            let size = sizeForCell(row: row, col: col)
                            let position = positionForCell(row: row, col: col)
                            
                            // Calculate the frame of the cell
                            let cellFrame = CGRect(
                                x: position.x - (size.width / 2),
                                y: position.y - (size.height / 2),
                                width: size.width,
                                height: size.height
                            )
                            
                            // Check if the cell is within the visible bounds
                            if visibleRect.intersects(cellFrame) {
                                if let image = viewModel.grid[row][col] {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: size.width, height: size.height)
                                        .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
                                }
                                else {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: size.width, height: size.height)
                                        .position(x: position.x + dragOffset.width, y: position.y + dragOffset.height)
                                        .onAppear {
                                            loadImage(row: row, col: col)
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
                    }
            )
        }
    }

    func sizeForCell(row: Int, col: Int) -> CGSize {
        if let image = viewModel.image {
            let tile = image.tile
            var size = CGSize(width: tile.width, height: tile.height)
            if row == image.rows - 1 {
                size.height = CGFloat(tile.lastRowHeight)
            }
            if col == image.cols - 1 {
                size.width = CGFloat(tile.lastColWidth)
            }
            return size
        }
        return .zero
    }

    func positionForCell(row: Int, col: Int) -> CGPoint {
        if let image = viewModel.image {
            let tile = image.tile
            var position: CGPoint = .zero
            if row == image.rows - 1 {
                position.y = CGFloat(row * tile.height + tile.lastRowHeight / 2)
            } else {
                position.y = CGFloat(row * tile.height + tile.height / 2)
            }
            if col == image.cols - 1 {
                position.x = CGFloat(col * tile.width + tile.lastColWidth / 2)
            } else {
                position.x = CGFloat(col * tile.width + tile.width / 2)
            }
            return position
        }
        return .zero
    }

    private func loadImage(row: Int, col: Int) {
        guard viewModel.concurrencyAllocations[row][col] == false else { return }
        viewModel.concurrencyAllocations[row][col] = true
        viewModel.numberOfBackgroundThreads += 1

        AF.request("\(viewModel.apiUrl)/v2/mosaics/\(viewModel.fileId)/zoom_level/\(viewModel.image!.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(viewModel.accessToken)").responseData { response in
            if let data = response.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    print("Got image: \(row),\(col)")
                    viewModel.grid[row][col] = image
                    viewModel.numberOfBackgroundThreads -= 1
                }
            }
        }
    }
}
