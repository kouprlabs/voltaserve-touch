import Foundation

struct Task {
    var config: Config
    var token: Token.Value

    enum SortBy: Decodable, CustomStringConvertible {
        case name
        case dateCreated
        case dateModified

        var description: String {
            switch self {
            case .name:
                "name"
            case .dateCreated:
                "date_created"
            case .dateModified:
                "date_modified"
            }
        }
    }

    enum SortOrder: String, Decodable {
        case asc
        case desc
    }

    struct Entity: Decodable {
        let id: String
        let name: String
        let error: String?
        let percentage: Int?
        let isIndeterminate: Bool
        let userId: String
        let status: Status
        let payload: Payload?
    }

    enum Status: String, Decodable {
        case waiting
        case running
        case success
        case error
    }

    struct Payload: Decodable {
        let taskObject: String?

        enum CodingKeys: String, CodingKey {
            case taskObject = "object"
        }
    }

    struct List: Decodable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
