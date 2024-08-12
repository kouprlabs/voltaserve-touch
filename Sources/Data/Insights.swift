import Foundation

struct Insights {
    var config: Config
    var token: Token.Value

    struct Language: Codable {
        let id: String
        let iso6393: String
        let name: String
    }

    struct Info: Codable {
        let isAvailable: Bool
        let isOutdated: Bool
        let snapshot: Snapshot.Entity?
    }

    struct Entity: Codable {
        let text: String
        let label: String
        let frequency: Int
    }

    struct EntityList: Codable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }

    enum SortBy: String, Codable {
        case name
        case frequency
    }

    enum SortOrder: String, Codable {
        case asc
        case sesc
    }
}
