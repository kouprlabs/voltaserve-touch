import Foundation

struct InsightsData {
    var config: Config
    var token: TokenData.Value

    struct Language: Decodable {
        let id: String
        let iso6393: String
        let name: String
    }

    struct Info: Decodable {
        let isAvailable: Bool
        let isOutdated: Bool
        let snapshot: SnapshotData.Entity?
    }

    struct Entity: Decodable {
        let text: String
        let label: String
        let frequency: Int
    }

    struct EntityList: Decodable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }

    enum SortBy: String, Decodable {
        case name
        case frequency
    }

    enum SortOrder: String, Decodable {
        case asc
        case sesc
    }
}
