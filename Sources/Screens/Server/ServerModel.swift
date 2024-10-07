import Foundation
import SwiftData

@Model
class Server {
    var id: String
    var name: String
    var apiURL: String
    var idpURL: String
    var isCloud: Bool
    var isActive: Bool
    static let cloud = Server(
        id: "cloud",
        name: "Voltaserve Cloud",
        apiURL: "https://api.cloud.voltaserve.com",
        idpURL: "https://idp.cloud.voltaserve.com",
        isCloud: true,
        isActive: true
    )

    init(id: String, name: String, apiURL: String, idpURL: String, isCloud: Bool, isActive: Bool) {
        self.id = id
        self.name = name
        self.apiURL = apiURL
        self.idpURL = idpURL
        self.isCloud = isCloud
        self.isActive = isActive
    }
}
