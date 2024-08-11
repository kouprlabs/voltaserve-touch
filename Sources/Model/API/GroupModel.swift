import Foundation

struct GroupModel {
    var config: Config
    var token: TokenModel.Token

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

    struct Group: Decodable {
        let id: String
        let name: String
        let organization: OrganizationModel.Organization
        let permission: String
        let createTime: String
        let updateTime: String?
    }

    struct List: Decodable {
        let data: [Group]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
    }
}
