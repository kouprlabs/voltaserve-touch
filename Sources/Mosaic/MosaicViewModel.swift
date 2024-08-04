import Alamofire
import SwiftUI

class MosaicViewModel: ObservableObject {
    @Published var grid: [[UIImage?]] = []
    @Published var concurrencyAllocations: [[Bool]] = []
    @Published var gridLoaded = false
    @Published var numberOfBackgroundThreads = 0

    var apiUrl: String = "http://localhost:8080"
    var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    var fileId: String = "w5JLDMQwLbkry"
    var image: MosaicZoomLevel?

    init() {
        AF.request(
            "\(apiUrl)/v2/mosaics/\(fileId)/info",
            headers: ["Authorization": "Bearer " + accessToken]
        ).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(MosaicInfo.self, from: data)
                    self.image = info.metadata.zoomLevels.first
                    DispatchQueue.main.async { [weak self] in
                        self?.fillGridWithImage()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func loadImage(row: Int, col: Int) {
        guard concurrencyAllocations[row][col] == false else { return }
        concurrencyAllocations[row][col] = true
        numberOfBackgroundThreads += 1

        AF.request("\(apiUrl)/v2/mosaics/\(fileId)/zoom_level/\(image!.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(accessToken)").responseData { response in
            if let data = response.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.grid[row][col] = image
                    self.numberOfBackgroundThreads -= 1
                }
            }
        }
    }

    func resetGrid() {
        gridLoaded = false
        grid = []
        concurrencyAllocations = []
    }

    func fillGridWithImage() {
        resetGrid()
        grid = Array(repeating: Array(repeating: nil, count: image!.cols), count: image!.rows)
        concurrencyAllocations = Array(repeating: Array(repeating: false, count: image!.cols), count: image!.rows)
        gridLoaded = true
    }

    func sizeForCell(row: Int, col: Int) -> CGSize {
        if let image {
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
        if let image {
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

    struct MosaicInfo: Codable {
        var metadata: MosaicMetadata
    }

    struct MosaicMetadata: Codable {
        var width: Int
        var height: Int
        var fileExtension: String
        var zoomLevels: [MosaicZoomLevel]

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
