import Foundation

extension UserDefaults {
    var server: Server? {
        get {
            if let data = data(forKey: Keys.server) {
                if let decoded = try? JSONDecoder().decode(Server.self, from: data) {
                    return decoded
                }
            }
            return nil
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                set(encoded, forKey: Keys.server)
            }
        }
    }

    private enum Keys {
        static let server = "com.voltaserve.server"
    }
}
