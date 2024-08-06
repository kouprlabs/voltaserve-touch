import Alamofire
import Foundation

struct MosaicStore {
    var config: Config
    var token: Token
    private(set) var zoomLevels: [ZoomLevel]?

    init(config: Config, token: Token) {
        self.config = config
        self.token = token
    }

    mutating func setZoomLevels(_ zoomLevels: [ZoomLevel]) {
        self.zoomLevels = zoomLevels
    }

    func fetchZoomLevelsForFile(id: String, completion: @escaping ([ZoomLevel]?, Error?) -> Void) {
        AF.request(
            "\(config.apiUrl)/v2/mosaics/\(id)/info",
            headers: ["Authorization": "Bearer \(token.accessToken)"]
        ).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(Info.self, from: data)
                    completion(info.metadata.zoomLevels, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }

    func fetchDataForFile(
        id: String,
        zoomLevel: ZoomLevel,
        forCellAtRow row: Int, col: Int,
        completion: @escaping (Data?) -> Void
    ) {
        // swiftlint:disable:next line_length
        AF.request("\(config.apiUrl)/v2/mosaics/\(id)/zoom_level/\(zoomLevel.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(token.accessToken)").responseData { response in
            if let data = response.data {
                completion(data)
            } else {
                completion(nil)
            }
        }
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
