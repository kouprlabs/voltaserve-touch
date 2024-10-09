import Foundation
import SwiftData

@Model
class Server: Codable {
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

    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        apiURL = try container.decode(String.self, forKey: .apiURL)
        idpURL = try container.decode(String.self, forKey: .idpURL)
        isCloud = try container.decode(Bool.self, forKey: .isCloud)
        isActive = try container.decode(Bool.self, forKey: .isActive)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(apiURL, forKey: .apiURL)
        try container.encode(idpURL, forKey: .idpURL)
        try container.encode(isCloud, forKey: .isCloud)
        try container.encode(isActive, forKey: .isActive)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case apiURL
        case idpURL
        case isCloud
        case isActive
    }
}
