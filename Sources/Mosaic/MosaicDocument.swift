import Alamofire
import SwiftUI

class MosaicDocument: ObservableObject {
    @Published var grid: [[UIImage?]] = []
    private var model = MosaicModel()
    private var busy: [[Bool]] = []
    private var apiUrl: String = "http://localhost:8080"
    // swiftlint:disable:next line_length
    private var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    private var fileId: String = "w5JLDMQwLbkry"

    var zoomLevel: MosaicModel.ZoomLevel? {
        model.zoomLevel
    }

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
                        self?.allocateGrid()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func loadImage(row: Int, col: Int) {
        guard busy[row][col] == false else { return }
        busy[row][col] = true

        if let image = model.zoomLevel {
            // swiftlint:disable:next line_length
            AF.request("\(apiUrl)/v2/mosaics/\(fileId)/zoom_level/\(image.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(accessToken)").responseData { response in
                if let data = response.data, let image = UIImage(data: data) {
                    self.busy[row][col] = false
                    DispatchQueue.main.async {
                        self.grid[row][col] = image
                    }
                }
            }
        }
    }

    func resetGrid() {
        grid = []
        busy = []
    }

    func allocateGrid() {
        resetGrid()

        if let zoomLevel = model.zoomLevel {
            grid = Array(repeating: Array(repeating: nil, count: zoomLevel.cols), count: zoomLevel.rows)
            busy = Array(
                repeating: Array(repeating: false, count: zoomLevel.cols),
                count: zoomLevel.rows
            )
        }
    }

    func sizeForCell(row: Int, col: Int) -> CGSize {
        model.sizeForCell(row: row, col: col)
    }

    func positionForCell(row: Int, col: Int) -> CGPoint {
        model.positionForCell(row: row, col: col)
    }

    func frameForCellAt(position: CGPoint, size: CGSize) -> CGRect {
        model.frameForCellAt(position: position, size: size)
    }
}
