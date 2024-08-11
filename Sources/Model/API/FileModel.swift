import Alamofire
import Foundation

struct FileModel {
    var config: Config
    var token: TokenModel.Token

    func fetch(id: String, completion: @escaping (File?, Error?) -> Void) {
        AF.request(
            URL(string: "\(config.apiUrl)/v2/files/\(id)")!,
            headers: headersWithAuthorization(token.accessToken)
        ).responseData { response in
            if let data = response.data {
                do {
                    let info = try JSONDecoder().decode(File.self, from: data)
                    completion(info, nil)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }

    func fetchSegmentedPage(id: String, _ page: Int, completion: @escaping (Data?, Error?) -> Void) {
        AF.request(
            urlForSegmentedPage(id: id, page: page),
            headers: headersWithAuthorization(token.accessToken)
        ).responseData { response in
            if let data = response.data {
                completion(data, nil)
            } else if let error = response.error {
                completion(nil, error)
            }
        }
    }

    func fetchSegmentedThumbnail(
        id: String,
        page: Int,
        fileExtension: String,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        AF.request(
            urlForSegmentedThumbnail(id: id, page: page, fileExtension: String(fileExtension.dropFirst())),
            headers: headersWithAuthorization(token.accessToken)
        ).responseData { response in
            if let data = response.data {
                completion(data, nil)
            } else if let error = response.error {
                completion(nil, error)
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

    struct File: Decodable {
        let id: String
        let workspaceId: String
        let name: String
        let type: FileType
        let parentId: String
        let permission: PermissionType
        let isShared: Bool
        let snapshot: SnapshotModel.Snapshot?
        let createTime: String
        let updateTime: String?
    }

    struct List: Decodable {
        let data: [File]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
        let query: Query?
    }

    struct UserPermission: Decodable {
        let id: String
        let user: APIUserModel.User
        let permission: String
    }

    struct GroupPermission: Decodable {
        let id: String
        let group: GroupModel.Group
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
