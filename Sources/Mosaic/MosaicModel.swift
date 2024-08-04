import Foundation

struct MosaicModel {
    var zoomLevel: MosaicModel.MosaicZoomLevel?

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

    struct MosaicInfo: Codable {
        var metadata: MosaicMetadata
    }

    struct MosaicMetadata: Codable {
        var width: Int
        var height: Int
        var fileExtension: String
        var zoomLevels: [MosaicZoomLevel]

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case width
            case height
            case fileExtension = "extension"
            case zoomLevels
        }
    }

    struct MosaicZoomLevel: Codable {
        var index: Int
        var width: Int
        var height: Int
        var rows: Int
        var cols: Int
        var scaleDownPercentage: Float
        var tile: MosaicTile
    }

    struct MosaicTile: Codable {
        var width: Int
        var height: Int
        var lastColWidth: Int
        var lastRowHeight: Int
    }
}
