import Alamofire
import Foundation

struct MosaicStore {
    var config: Config
    var token: Token
    private(set) var info: Info?

    init(config: Config, token: Token) {
        self.config = config
        self.token = token
    }

    mutating func setInfo(_ info: Info) {
        self.info = info
    }

    func fetchInfoForFile(id: String, completion: @escaping (Info?, Error?) -> Void) {
        AF.request(
            "\(config.apiUrl)/v2/mosaics/\(id)/info",
            headers: ["Authorization": "Bearer \(token.accessToken)"]
        ).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(Info.self, from: data)
                    completion(info, nil)
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
        fileExtenion: String,
        completion: @escaping (Data?) -> Void
    ) {
        let url = "\(config.apiUrl)/v2/mosaics/\(id)/zoom_level/\(zoomLevel.index)" +
            "/row/\(row)/col/\(col)/ext/\(fileExtenion)?access_token=\(token.accessToken)"
        AF.request(url).responseData { response in
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
