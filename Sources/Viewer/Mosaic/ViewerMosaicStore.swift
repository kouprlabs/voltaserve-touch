import SwiftUI
import Voltaserve

class ViewerMosaicStore: ObservableObject {
    @Published private(set) var info: VOMosaic.Info?
    @Published private(set) var zoomLevel: VOMosaic.ZoomLevel?
    @Published private(set) var grid: [[UIImage?]] = []

    private var busy: [[Bool]] = []
    private var client: VOMosaic?

    var token: VOToken.Value? {
        didSet {
            if let token {
                client = .init(
                    baseURL: Config.production.apiURL,
                    accessToken: token.accessToken
                )
            }
        }
    }

    func loadMosaic(_ id: String) async throws {
        let info = try await client?.fetchInfo(id)
        if let info {
            Task { @MainActor in
                self.info = info
                if let zoomLevel = self.info?.metadata.zoomLevels.first {
                    self.zoomLevel = zoomLevel
                    self.allocateGridForZoomLevel(zoomLevel)
                }
            }
        }
    }

    private func allocateGridForZoomLevel(_ zoomLevel: VOMosaic.ZoomLevel) {
        grid = Array(repeating: Array(repeating: nil, count: zoomLevel.cols), count: zoomLevel.rows)
        busy = Array(
            repeating: Array(repeating: false, count: zoomLevel.cols),
            count: zoomLevel.rows
        )
    }

    func selectZoomLevel(_ zoomLevel: VOMosaic.ZoomLevel) {
        self.zoomLevel = zoomLevel
        allocateGridForZoomLevel(zoomLevel)
    }

    func loadImageForCell(_ id: String, row: Int, col: Int) {
        guard busy[row][col] == false else { return }
        busy[row][col] = true
        if let zoomLevel, let info {
            Task {
                let data = try await client?.fetchData(
                    id,
                    zoomLevel: zoomLevel,
                    forCellAtRow: row, col: col,
                    fileExtension: String(info.metadata.fileExtension.dropFirst())
                )
                if let data {
                    self.busy[row][col] = false
                    Task { @MainActor in
                        self.grid[row][col] = UIImage(data: data)
                    }
                }
            }
        }
    }

    func unloadImagesOutsideRect(_ visibleRect: CGRect, extraTilesToLoad: Int) {
        guard let zoomLevel else { return }

        for row in 0 ..< zoomLevel.rows {
            for col in 0 ..< zoomLevel.cols {
                let size = sizeForCell(row: row, col: col)
                let position = positionForCell(row: row, col: col)
                let frame = frameForCellAt(position: position, size: size)
                if !visibleRect.insetBy(
                    dx: -CGFloat(extraTilesToLoad) * size.width,
                    dy: -CGFloat(extraTilesToLoad) * size.height
                ).intersects(frame) {
                    grid[row][col] = nil
                }
            }
        }
    }

    func sizeForCell(row: Int, col: Int) -> CGSize {
        if let zoomLevel {
            let tile = zoomLevel.tile
            var size = CGSize(width: tile.width, height: tile.height)
            if row == zoomLevel.rows - 1 {
                size.height = CGFloat(tile.lastRowHeight)
            }
            if col == zoomLevel.cols - 1 {
                size.width = CGFloat(tile.lastColWidth)
            }
            return size
        }
        return .zero
    }

    func positionForCell(row: Int, col: Int) -> CGPoint {
        if let zoomLevel {
            let tile = zoomLevel.tile
            var position: CGPoint = .zero
            if row == zoomLevel.rows - 1 {
                position.y = CGFloat(row * tile.height + tile.lastRowHeight / 2)
            } else {
                position.y = CGFloat(row * tile.height + tile.height / 2)
            }
            if col == zoomLevel.cols - 1 {
                position.x = CGFloat(col * tile.width + tile.lastColWidth / 2)
            } else {
                position.x = CGFloat(col * tile.width + tile.width / 2)
            }
            return position
        }
        return .zero
    }

    func frameForCellAt(position: CGPoint, size: CGSize) -> CGRect {
        CGRect(
            x: position.x - (size.width / 2),
            y: position.y - (size.height / 2),
            width: size.width,
            height: size.height
        )
    }
}
