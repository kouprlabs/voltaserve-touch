import Alamofire
import SwiftUI

class MosaicDocument: ObservableObject {
    @Published var grid: [[UIImage?]] = []
    var model = MosaicModel()
    private var busy: [[Bool]] = []
    private var apiUrl: String = "http://localhost:8080"
    // swiftlint:disable:next line_length
    private var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    private var fileId: String = "w5JLDMQwLbkry"

    var zoomLevel: MosaicModel.ZoomLevel? {
        model.zoomLevel
    }

    init() {
        loadMosaicInfo()
    }

    func loadMosaicInfo() {
        AF.request(
            "\(apiUrl)/v2/mosaics/\(fileId)/info",
            headers: ["Authorization": "Bearer " + accessToken]
        ).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(MosaicModel.Info.self, from: data)
                    self.model.zoomLevels = info.metadata.zoomLevels
                    DispatchQueue.main.async {
                        self.model.zoomLevel = self.model.zoomLevels?.first
                        self.allocateGrid()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func selectZoomLevel(_ zoomLevel: MosaicModel.ZoomLevel) {
        model.zoomLevel = zoomLevel
        allocateGrid()
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

    func unloadImagesOutsideBuffer(visibleRect: CGRect, extraTilesToLoad: Int) {
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
