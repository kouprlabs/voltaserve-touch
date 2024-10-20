import Foundation

struct Config {
    var apiURL: String
    var idpURL: String

    static var production: Config {
        if let server = UserDefaults.standard.server {
            Config(
                apiURL: server.apiURL,
                idpURL: server.idpURL
            )
        } else {
            Config(
                apiURL: "https://api.cloud.voltaserve.com",
                idpURL: "https://idp.cloud.voltaserve.com"
            )
        }
    }
}
