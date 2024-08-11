import Alamofire
import Foundation

struct File {
    var config: Config
    var token: Token.Value

    func fetch(id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                URL(string: "\(config.apiUrl)/v2/files/\(id)")!,
                headers: headersWithAuthorization(token.accessToken)
            ).responseData { response in
                if let data = response.data {
                    do {
                        let result = try JSONDecoder().decode(Entity.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: FileError.unknown)
                }
            }
        }
    }

    func fetchSegmentedPage(id: String, page: Int) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedPage(id: id, page: page),
                headers: headersWithAuthorization(token.accessToken)
            ).responseData { response in
                if let data = response.data {
                    continuation.resume(returning: data)
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: FileError.unknown)
                }
            }
        }
    }

    func fetchSegmentedThumbnail(id: String, page: Int, fileExtension: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedThumbnail(id: id, page: page, fileExtension: String(fileExtension.dropFirst())),
                headers: headersWithAuthorization(token.accessToken)
            ).responseData { response in
                if let data = response.data {
                    continuation.resume(returning: data)
                } else if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: FileError.unknown)
                }
            }
        }
    }

    func urlForOriginal(id: String, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/original.\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    func urlForPreview(id: String, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/preview.\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    func urlForSegmentedPage(id: String, page: Int) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/segmentation/pages/\(page).pdf?" +
            "access_token=\(token.accessToken)")!
    }

    func urlForSegmentedThumbnail(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/segmentation/thumbnails/\(page).\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    enum FileError: Error {
        case unknown
    }

    enum FileType: String, Decodable {
        case file
        case folder
    }

    enum SortBy: String, Decodable, CustomStringConvertible {
        case name
        case kind
        case size
        case dateCreated
        case dateModified

        var description: String {
            switch self {
            case .name:
                "name"
            case .kind:
                "kind"
            case .size:
                "size"
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
        let workspaceId: String
        let name: String
        let type: FileType
        let parentId: String
        let permission: PermissionType
        let isShared: Bool
        let snapshot: Snapshot.Entity?
        let createTime: String
        let updateTime: String?
    }

    struct List: Decodable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
        let query: Query?
    }

    struct UserPermission: Decodable {
        let id: String
        let user: User.Entity
        let permission: String
    }

    struct GroupPermission: Decodable {
        let id: String
        let group: Group.Entity
        let permission: String
    }

    struct Query: Decodable {
        let text: String
        let type: FileType?
        let createTimeAfter: Int?
        let createTimeBefore: Int?
        let updateTimeAfter: Int?
        let updateTimeBefore: Int?
    }

    enum PermissionType: String, Decodable {
        case viewer
        case editor
        case owner
    }
}
