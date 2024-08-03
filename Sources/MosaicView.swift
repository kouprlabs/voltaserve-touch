import SwiftUI
import Combine
import UIKit
import Alamofire

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
    @Published var documentLocation: CGPoint = .zero
    @Published var touchLocation: CGPoint = .zero
    @Published var delta: CGPoint = .zero
    @Published var rowCount: Int = 0
    @Published var colCount: Int = 0
    @Published var gridLoaded: Bool = false
    @Published var touchDown: Bool = false
    @Published var index: Int = 0
    @Published var divWidth: Int = 0
    @Published var divHeight: Int = 0
    @Published var numberOfBackgroundThreads: Int = 0
    
    var apiUrl: String = "http://localhost:8080"
    var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    var fileId: String = "w5JLDMQwLbkry"
    var image: MosaicZoomLevel?
    
    init() {
        print("it started!")
        
        AF.request(
            "\(apiUrl)/v2/mosaics/\(fileId)/info",
            headers: ["Authorization": "Bearer " + accessToken]).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(MosaicInfo.self, from: data)
                    print(info)
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.fillGridWithImage(info.metadata.zoomLevels[0])
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
        documentLocation = .zero
        delta = .zero
        rowCount = 0
        colCount = 0
    }
    
    func fillGridWithImage(_ image: MosaicZoomLevel) {
        resetGrid()
        
        index = image.index
        rowCount = image.rows
        colCount = image.cols
        divWidth = image.tile.width
        divHeight = image.tile.height
        
        grid = Array(repeating: Array(repeating: nil, count: colCount), count: rowCount)
        concurrencyAllocations = Array(repeating: Array(repeating: false, count: colCount), count: rowCount)
        
        gridLoaded = true
    }
}

struct MosaicView: View {
    @ObservedObject var viewModel: MosaicViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if viewModel.gridLoaded {
                    ForEach(0..<viewModel.rowCount, id: \.self) { row in
                        ForEach(0..<viewModel.colCount, id: \.self) { col in
                            if let image = viewModel.grid[row][col] {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: CGFloat(viewModel.divWidth), height: CGFloat(viewModel.divHeight))
                                    .position(x: CGFloat(col * viewModel.divWidth) + viewModel.documentLocation.x,
                                              y: CGFloat(row * viewModel.divHeight) + viewModel.documentLocation.y)
                            } else {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: CGFloat(viewModel.divWidth), height: CGFloat(viewModel.divHeight))
                                    .position(x: CGFloat(col * viewModel.divWidth) + viewModel.documentLocation.x,
                                              y: CGFloat(row * viewModel.divHeight) + viewModel.documentLocation.y)
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
                        if viewModel.touchDown {
                            viewModel.documentLocation.x = value.location.x - viewModel.delta.x
                            viewModel.documentLocation.y = value.location.y - viewModel.delta.y
                        }
                    }
                    .onEnded { value in
                        viewModel.touchDown = false
                    }
            )
            .onTapGesture {
                viewModel.touchDown = true
                viewModel.touchLocation = CGPoint(x: 0, y: 0)
            }
        }
    }
    
    private func loadImage(row: Int, col: Int) {
        guard viewModel.concurrencyAllocations[row][col] == false else { return }
        
        viewModel.concurrencyAllocations[row][col] = true
        viewModel.numberOfBackgroundThreads += 1
        
        AF.request("\(viewModel.apiUrl)/v2/mosaics/\(viewModel.fileId)/zoom_level/\(viewModel.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(viewModel.accessToken)").responseData { response in
            if let data = response.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    viewModel.grid[row][col] = image
                    viewModel.numberOfBackgroundThreads -= 1
                }
            }
        }
    }
}
