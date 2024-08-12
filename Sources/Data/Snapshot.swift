import Foundation

struct Snapshot {
    var config: Config
    var token: Token.Value

    enum SortBy: Codable, CustomStringConvertible {
        case version
        case dateCreated
        case dateModified

        var description: String {
            switch self {
            case .version:
                "version"
            case .dateCreated:
                "date_created"
            case .dateModified:
                "date_modified"
            }
        }
    }

    enum SortOrder: String, Codable {
        case asc
        case desc
    }

    struct Entity: Codable {
        let id: String
        let version: Int
        let status: Status
        let original: Download
        let preview: Download?
        let ocr: Download?
        let text: Download?
        let entities: Download?
        let mosaic: Download?
        let segmentation: Download?
        let thumbnail: Download?
        let language: String?
        let isActive: Bool
        let task: TaskInfo?
        let createTime: String
        let updateTime: String?
    }

    struct List: Codable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }

    enum Status: String, Codable {
        case waiting
        case processing
        case ready
        case error
    }

    struct TaskInfo: Codable {
        let id: String
        let isPending: Bool
    }

    struct Download: Codable {
        let fileExtension: String?
        let size: Int?
        let image: ImageProps?
        let document: DocumentProps?

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
            case size
            case image
            case document
        }
    }

    struct ImageProps: Codable {
        let width: Int
        let height: Int
        let zoomLevels: [ZoomLevel]?
    }

    struct DocumentProps: Codable {
        let pages: PagesProps?
        let thumbnails: ThumbnailsProps?
    }

    struct PagesProps: Codable {
        let count: Int
        let fileExtension: String

        enum CodingKeys: String, CodingKey {
            case count
            case fileExtension = "extension"
        }
    }

    struct ThumbnailsProps: Codable {
        let fileExtension: String

        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
        }
    }

    struct Tile: Codable {
        let width: Int
        let height: Int
        let lastColWidth: Int
        let lastRowHeight: Int
    }

    struct ZoomLevel: Codable {
        let index: Int
        let width: Int
        let height: Int
        let rows: Int
        let cols: Int
        let scaleDownPercentage: Int
        let tile: Tile
    }
}
