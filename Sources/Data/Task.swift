import Foundation

struct TaskData {
    var config: Config
    var token: Token.Value

    enum SortBy: Codable, CustomStringConvertible {
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

    enum SortOrder: String, Codable {
        case asc
        case desc
    }

    struct Entity: Codable {
        let id: String
        let name: String
        let error: String?
        let percentage: Int?
        let isIndeterminate: Bool
        let userId: String
        let status: Status
        let payload: Payload?
    }

    enum Status: String, Codable {
        case waiting
        case running
        case success
        case error
    }

    struct Payload: Codable {
        let taskObject: String?

        enum CodingKeys: String, CodingKey {
            case taskObject = "object"
        }
    }

    struct List: Codable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
