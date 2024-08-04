import SwiftUI
import Alamofire

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
                        print("Got info!")
                        self?.fillGridWithImage()
                    }
                } catch {
                    print(error.localizedDescription)
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
