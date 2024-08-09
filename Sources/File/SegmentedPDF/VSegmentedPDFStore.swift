import Alamofire
import Foundation

struct VSegmentedPDFStore {
    var config: Config
    var token: Token

    func urlForFile(id: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)?access_token=\(token.accessToken)")!
    }

    func urlForPreview(id: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/preview.pdf?access_token=\(token.accessToken)")!
    }

    func urlForSegmentedPage(id: String, page: Int) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/segmentation/pages/\(page).pdf?access_token=\(token.accessToken)")!
    }

    func urlForSegmentedThumbnail(id: String, page: Int) -> URL {
        // swiftlint:disable:next line_length
        URL(string: "\(config.apiUrl)/v2/files/\(id)/segmentation/thumbnails/\(page).jpg?access_token=\(token.accessToken)")!
    }

    func fetchFile(id: String, completion: @escaping (File?, Error?) -> Void) {
        AF.request(
            urlForFile(id: id),
            headers: ["Authorization": "Bearer \(token.accessToken)"]
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
            headers: ["Authorization": "Bearer \(token.accessToken)"]
        ).responseData { response in
            if let data = response.data {
                completion(data, nil)
            } else if let error = response.error {
                completion(nil, error)
            }
        }
    }

    func fetchSegmentedThumbnail(id: String, _ page: Int, completion: @escaping (Data?, Error?) -> Void) {
        AF.request(
            urlForSegmentedThumbnail(id: id, page: page),
            headers: ["Authorization": "Bearer \(token.accessToken)"]
        ).responseData { response in
            if let data = response.data {
                completion(data, nil)
            } else if let error = response.error {
                completion(nil, error)
            }
        }
    }

    enum FileType: String, Decodable {
        case file
        case folder
    }

    enum PermissionType: String, Decodable {
        case viewer
        case editor
        case owner
    }

    enum Status: String, Decodable {
        case waiting
        case processing
        case ready
        case error
    }

    struct File: Decodable {
        let id: String
        let workspaceId: String
        let name: String
        let type: FileType
        let parentId: String
        let permission: PermissionType
        let isShared: Bool
        let snapshot: Snapshot?
        let createTime: String
        let updateTime: String?
    }

    struct Snapshot: Decodable {
        let id: String
        let version: Int
        let status: Status
        let original: Download
        let preview: Download?
        let ocr: Download?
        let text: Download?
        let entities: Download?
        let mosaic: Download?
        let segmentation: Download?
        let thumbnail: Download?
        let language: String?
        let isActive: Bool
        let task: TaskInfo?
        let createTime: String
        let updateTime: String?
    }

    struct TaskInfo: Decodable {
        let id: String
        let isPending: Bool
    }

    struct Download: Decodable {
        let fileExtension: String?
        let size: Int?
        let image: ImageProps?
        let document: DocumentProps?
        let page: PageProps?
        let thumbnail: ThumbnailProps?

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
            case size
            case image
            case document
            case page
            case thumbnail
        }
    }

    struct ImageProps: Decodable {
        let width: Int
        let height: Int
    }

    struct DocumentProps: Decodable {
        let pages: Int
    }

    struct PageProps: Decodable {
        let fileExtension: String

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
        }
    }

    struct ThumbnailProps: Decodable {
        let fileExtension: String

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case fileExtension = "extension"
        }
    }
}
