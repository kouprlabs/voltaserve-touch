import Foundation

struct StorageModel {
    var config: Config
    var token: TokenModel.Token

    struct StorageUsage: Decodable {
        let bytes: Int
        let maxBytes: Int
        let percentage: Int
    }
}
