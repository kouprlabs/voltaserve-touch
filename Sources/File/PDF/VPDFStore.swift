import Foundation

struct VPDFStore {
    var config: Config
    var token: Token

    func urlForFile(id: String) -> URL {
        URL(string: "\(config.apiUrl)/v2/files/\(id)/preview.pdf?access_token=\(token.accessToken)")!
    }
}
