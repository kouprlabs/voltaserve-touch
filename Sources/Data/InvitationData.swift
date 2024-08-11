import Foundation

struct InvitationData {
    var config: Config
    var token: TokenData.Value

    enum SortBy: Decodable, CustomStringConvertible {
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

    enum SortOrder: String, Decodable {
        case asc
        case desc
    }

    enum InvitationStatus: String, Decodable {
        case pending
        case accepted
        case declined
    }

    struct Entity: Decodable {
        let id: String
        let owner: UserData.Entity
        let email: [String]
        let organization: OrganizationData.Entity
        let status: InvitationStatus
        let createTime: String
        let updateTime: String?
    }

    struct List: Decodable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
