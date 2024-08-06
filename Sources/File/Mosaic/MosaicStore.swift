import Alamofire
import UIKit

struct MosaicStore {
    private(set) var zoomLevels: [ZoomLevel]?
    private var apiUrl: String = "http://localhost:8080"
    // swiftlint:disable:next line_length
    private var accessToken: String = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJaeEtHcWJXTmIiLCJpYXQiOjE3MjIxMjg1NDUsImlzcyI6ImxvY2FsaG9zdCIsImF1ZCI6ImxvY2FsaG9zdCIsImV4cCI6MTcyNDcyMDU0NX0.xge1u8rXuaWWGHIXkRduDX7iJ0dsLgKGwoodZ8qU55Y"
    private var fileId: String = "w5JLDMQwLbkry"

    mutating func setZoomLevels(_ zoomLevels: [ZoomLevel]) {
        self.zoomLevels = zoomLevels
    }

    mutating func fetchZoomLevels(completion: @escaping ([ZoomLevel]?, Error?) -> Void) {
        AF.request(
            "\(apiUrl)/v2/mosaics/\(fileId)/info",
            headers: ["Authorization": "Bearer " + accessToken]
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

    mutating func fetchDataAtZoomLevel(
        _ zoomLevel: ZoomLevel,
        forCellAtRow row: Int, col: Int,
        completion: @escaping (Data?) -> Void
    ) {
        // swiftlint:disable:next line_length
        AF.request("\(apiUrl)/v2/mosaics/\(fileId)/zoom_level/\(zoomLevel.index)/row/\(row)/col/\(col)/ext/jpg?access_token=\(accessToken)").responseData { response in
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
