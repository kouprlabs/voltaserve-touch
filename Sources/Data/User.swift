import Foundation

struct User {
    var config: Config
    var token: Token.Value

    enum SortBy: Decodable, CustomStringConvertible {
        case email
        case fullName

        var description: String {
            switch self {
            case .email:
                "email"
            case .fullName:
                "full_name"
            }
        }
    }

    enum SortOrder: String, Decodable {
        case asc
        case desc
    }

    struct Entity: Decodable {
        let id: String
        let username: String
        let email: String
        let fullName: String
        let picture: String?
    }

    struct List: Decodable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
