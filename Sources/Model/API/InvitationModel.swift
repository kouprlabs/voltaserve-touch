import Foundation

struct InvitationModel {
    var config: Config
    var token: TokenModel.Token

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

    struct Invitation: Decodable {
        let id: String
        let owner: APIUserModel.User
        let email: [String]
        let organization: OrganizationModel.Organization
        let status: InvitationStatus
        let createTime: String
        let updateTime: String?
    }

    struct List: Decodable {
        let data: [Invitation]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
