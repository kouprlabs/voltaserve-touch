import Foundation

struct StorageData {
    var config: Config
    var token: TokenData.Value

    struct Usage: Decodable {
        let bytes: Int
        let maxBytes: Int
        let percentage: Int
    }
}
