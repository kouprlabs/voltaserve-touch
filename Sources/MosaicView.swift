import Alamofire
import Combine
import SwiftUI
import UIKit

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

class MosaicViewModel: ObservableObject {
    @Published var grid: [[UIImage?]] = []
    @Published var concurrencyAllocations: [[Bool]] = []
    @Published var touchLocation: CGPoint = .zero
    @Published var gridLoaded = false
    @Published var numberOfBackgroundThreads: Int = 0

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

                    self.image = info.metadata.zoomLevels[9]

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
}

struct MosaicView: View {
    @ObservedObject var viewModel: MosaicViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.gridLoaded, viewModel.image != nil {
                    ForEach(0 ..< viewModel.image!.rows, id: \.self) { row in
                        ForEach(0 ..< viewModel.image!.cols, id: \.self) { col in
                            if let image = viewModel.grid[row][col] {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: CGFloat(viewModel.image!.tile.width), height: CGFloat(viewModel.image!.tile.height))
                                    .position(x: CGFloat(col * viewModel.image!.tile.width),
                                              y: CGFloat(row * viewModel.image!.tile.height))
                            } else {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: CGFloat(viewModel.image!.tile.width), height: CGFloat(viewModel.image!.tile.height))
                                    .position(x: CGFloat(col * viewModel.image!.tile.width),
                                              y: CGFloat(row * viewModel.image!.tile.height))
                                    .onAppear {
                                        loadImage(row: row, col: col)
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
                        viewModel.touchLocation = value.location
                        print("DragGesture.onChanged: (\(viewModel.touchLocation.x), \(viewModel.touchLocation.y))")
                    }
            )
        }
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
