import Foundation

struct Config {
    var apiURL: String
    var idpURL: String

    static let production = Config(
        apiURL: "http://localhost:8080/v2",
        idpURL: "http://localhost:8081/v2"
    )
}
