import Foundation

struct V3DStore {
    var config: Config
    var token: Token

    func urlForFile(id: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/preview.glb?access_token=\(token.accessToken)")!
    }
}
