import Foundation

struct MosaicModel {
    var zoomLevel: ZoomLevel?
    var zoomLevels: [ZoomLevel]?

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

    struct Info: Codable {
        var metadata: Metadata
    }

    struct Metadata: Codable {
        var width: Int
        var height: Int
        var fileExtension: String
        var zoomLevels: [ZoomLevel]

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case width
            case height
            case fileExtension = "extension"
            case zoomLevels
        }
    }

    struct ZoomLevel: Codable {
        var index: Int
        var width: Int
        var height: Int
        var rows: Int
        var cols: Int
        var scaleDownPercentage: Float
        var tile: Tile
    }

    struct Tile: Codable {
        var width: Int
        var height: Int
        var lastColWidth: Int
        var lastRowHeight: Int
    }
}
