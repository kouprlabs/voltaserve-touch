import Foundation

struct WorkspaceData {
    var config: Config
    var token: TokenData.Value

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
        let permission: PermissionData.Value
        let storageCapacity: Int
        let rootId: String
        let organization: OrganizationData.Entity
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
