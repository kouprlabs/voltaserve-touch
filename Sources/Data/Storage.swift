import Foundation

struct Storage {
    var config: Config
    var token: Token.Value

    struct Usage: Codable {
        let bytes: Int
        let maxBytes: Int
        let percentage: Int
    }
}
