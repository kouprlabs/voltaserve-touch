import Alamofire
import Combine
import SwiftUI
import UIKit

struct MosaicView: View {
    @ObservedObject var document: MosaicDocument
    @State private var dragOffset = CGSize.zero
    @State private var lastDragOffset = CGSize.zero

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

                            // Calculate the frame of the cell
                            let cellFrame = CGRect(
                                x: position.x - (size.width / 2),
                                y: position.y - (size.height / 2),
                                width: size.width,
                                height: size.height
                            )

                            // Check if the cell is within the visible bounds
                            if visibleRect.intersects(cellFrame) {
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
                                            document.loadImage(row: row, col: col)
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
}
