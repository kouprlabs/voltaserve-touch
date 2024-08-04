import Alamofire
import SwiftUI

class MosaicDocument: ObservableObject {
    private(set) var model = MosaicModel()
    @Published var grid: [[UIImage?]] = []
    @Published var concurrentAllocations: [[Bool]] = []
    @Published var gridLoaded = false
    @Published var backgroundThreadCount = 0

    var zoomLevel: MosaicModel.ZoomLevel? {
        model.zoomLevel
    }

    var apiUrl: String = "http://localhost:8080"
    // swiftlint:disable:next line_length
    var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    var fileId: String = "w5JLDMQwLbkry"

    init() {
        AF.request(
            "\(apiUrl)/v2/mosaics/\(fileId)/info",
            headers: ["Authorization": "Bearer " + accessToken]
        ).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(MosaicModel.Info.self, from: data)
                    self.model.zoomLevel = info.metadata.zoomLevels.first
                    DispatchQueue.main.async { [weak self] in
                        self?.fillGridWithImage()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func sizeForCell(row: Int, col: Int) -> CGSize {
        model.sizeForCell(row: row, col: col)
    }

    func positionForCell(row: Int, col: Int) -> CGPoint {
        model.positionForCell(row: row, col: col)
    }

    func loadImage(row: Int, col: Int) {
        guard concurrentAllocations[row][col] == false else { return }
        concurrentAllocations[row][col] = true

        backgroundThreadCount += 1

        if let image = model.zoomLevel {
            // swiftlint:disable:next line_length
            AF.request("\(apiUrl)/v2/mosaics/\(fileId)/zoom_level/\(image.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(accessToken)").responseData { response in
                if let data = response.data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.grid[row][col] = image
                        self.backgroundThreadCount -= 1
                    }
                }
            }
        }
    }

    func resetGrid() {
        gridLoaded = false
        grid = []
        concurrentAllocations = []
    }

    func fillGridWithImage() {
        resetGrid()

        if let zoomLevel = model.zoomLevel {
            grid = Array(repeating: Array(repeating: nil, count: zoomLevel.cols), count: zoomLevel.rows)
            concurrentAllocations = Array(
                repeating: Array(repeating: false, count: zoomLevel.cols),
                count: zoomLevel.rows
            )
        }

        gridLoaded = true
    }
}
