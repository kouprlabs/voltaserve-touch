import Foundation

struct Invitation {
    var config: Config
    var token: Token.Value

    enum SortBy: Codable, CustomStringConvertible {
        case email
        case dateCreated
        case dateModified

        var description: String {
            switch self {
            case .email:
                "email"
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

    enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case declined
    }

    struct Entity: Codable {
        let id: String
        let owner: User.Entity
        let email: [String]
        let organization: Organization.Entity
        let status: InvitationStatus
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
}
