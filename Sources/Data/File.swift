import Alamofire
import Foundation

struct File {
    var config: Config
    var token: Token.Value

    func fetch(id: String) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlFor(id: id),
                headers: headersWithAuthorization(token.accessToken)
            ).responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let result = try JSONDecoder().decode(Entity.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func fetchSegmentedPage(id: String, page: Int, fileExtension: String) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlForSegmentedPage(id: id, page: page, fileExtension: fileExtension),
                headers: headersWithAuthorization(token.accessToken)
            ).responseData { response in
                switch response.result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
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
                switch response.result {
                case let .success(data):
                    continuation.resume(returning: data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    struct CreateOptions {
        let type: FileType
        let workspaceID: String
        let parentID: String?
        let name: String?
        let data: Data?
        let onProgress: ((Double) -> Void)?
    }

    func create(_ options: CreateOptions) async throws -> Entity {
        switch options.type {
        case .file:
            try await upload(url: urlForCreateOptions(options), method: .post, data: options.data!)
        case .folder:
            try await withCheckedThrowingContinuation { continuation in
                AF.request(
                    urlForCreateOptions(options),
                    method: .post,
                    headers: headersWithAuthorization(token.accessToken)
                ).responseData { response in
                    switch response.result {
                    case let .success(data):
                        do {
                            let result = try JSONDecoder().decode(Entity.self, from: data)
                            continuation.resume(returning: result)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    func patch(id: String, data _: Data) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlFor(id: id),
                method: .patch,
                headers: headersWithAuthorization(token.accessToken)
            ).responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let result = try JSONDecoder().decode(Entity.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func upload(
        url: URL,
        method: HTTPMethod,
        data: Data,
        onProgress: ((Double) -> Void)? = nil
    ) async throws -> Entity {
        try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: "file")
            }, to: url, method: method, headers: headersWithAuthorization(token.accessToken))
                .uploadProgress { progress in
                    onProgress?(progress.fractionCompleted * 100)
                }
                .responseData { response in
                    switch response.result {
                    case let .success(data):
                        do {
                            let result = try JSONDecoder().decode(Entity.self, from: data)
                            continuation.resume(returning: result)
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
        }
    }

    struct ListOptions: Codable {
        let size: Int?
        let page: Int?
        let type: FileType?
        let sortBy: SortBy?
        let sortOrder: SortOrder?
        let query: Query?
    }

    func list(id: String, options: ListOptions) async throws -> List {
        try await withCheckedThrowingContinuation { continuation in
            AF.request(
                urlFor(id: id, listOptions: options),
                method: .post,
                parameters: options,
                encoder: JSONParameterEncoder.default
            ).responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let result = try JSONDecoder().decode(List.self, from: data)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func urlFor(id: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)")!
    }

    func urlFor(id: String, listOptions options: ListOptions) -> URL {
        var urlComponents = URLComponents()
        if let page = options.page {
            urlComponents.queryItems?.append(URLQueryItem(name: "page", value: String(page)))
        }
        if let size = options.size {
            urlComponents.queryItems?.append(URLQueryItem(name: "size", value: String(size)))
        }
        if let sortBy = options.sortBy {
            urlComponents.queryItems?.append(URLQueryItem(name: "sort_by", value: sortBy.rawValue))
        }
        if let sortOrder = options.sortOrder {
            urlComponents.queryItems?.append(URLQueryItem(name: "sort_order", value: sortOrder.rawValue))
        }
        if let type = options.type {
            urlComponents.queryItems?.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if let query = options.query {
            if let base64Query = try? JSONEncoder().encode(query).base64EncodedString() {
                urlComponents.queryItems?.append(URLQueryItem(name: "query", value: base64Query))
            }
        }
        let query = urlComponents.url?.query
        if let query {
            return URL(string: "\(config.apiUrl)/v2/files/\(id)?\(query)")!
        } else {
            return URL(string: "\(config.apiUrl)/v2/files/\(id)")!
        }
    }

    func urlForCreateOptions(_ options: CreateOptions) -> URL {
        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "type", value: options.type.rawValue),
            URLQueryItem(name: "workspace_id", value: options.workspaceID)
        ]
        if let parentID = options.parentID {
            urlComponents.queryItems?.append(URLQueryItem(name: "parent_id", value: parentID))
        }
        if let name = options.name {
            urlComponents.queryItems?.append(URLQueryItem(name: "name", value: name))
        }
        let query = urlComponents.url?.query
        return URL(string: "\(config.apiUrl)/v2/files?" + query!)!
    }

    func urlForOriginal(id: String, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/original.\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    func urlForPreview(id: String, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/preview.\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    func urlForSegmentedPage(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/segmentation/pages/\(page).\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    func urlForSegmentedThumbnail(id: String, page: Int, fileExtension: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/segmentation/thumbnails/\(page).\(fileExtension)?" +
            "access_token=\(token.accessToken)")!
    }

    enum FileType: String, Codable {
        case file
        case folder
    }

    enum SortBy: String, Codable, CustomStringConvertible {
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

    enum SortOrder: String, Codable {
        case asc
        case desc
    }

    struct Entity: Codable {
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

    struct List: Codable {
        let data: [Entity]
        let totalPages: Int
        let totalElements: Int
        let page: Int
        let size: Int
        let query: Query?
    }

    struct UserPermission: Codable {
        let id: String
        let user: User.Entity
        let permission: String
    }

    struct GroupPermission: Codable {
        let id: String
        let group: Group.Entity
        let permission: String
    }

    struct Query: Codable {
        let text: String
        let type: FileType?
        let createTimeAfter: Int?
        let createTimeBefore: Int?
        let updateTimeAfter: Int?
        let updateTimeBefore: Int?

        static func encodeToBase64(_ value: String) -> String {
            guard let data = value.data(using: .utf8) else {
                return ""
            }
            return data.base64EncodedString()
        }

        static func decodeFromBase64(_ value: String) -> String? {
            guard !value.isEmpty, let data = Data(base64Encoded: value) else {
                return nil
            }
            return String(decoding: data, as: UTF8.self)
        }
    }

    enum PermissionType: String, Codable {
        case viewer
        case editor
        case owner
    }
}
