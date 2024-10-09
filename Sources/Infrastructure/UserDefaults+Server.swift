import Foundation

extension UserDefaults {
    var server: Server? {
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                set(encoded, forKey: Keys.server)
            }
        }
        get {
            if let data = data(forKey: Keys.server) {
                if let decoded = try? JSONDecoder().decode(Server.self, from: data) {
                    return decoded
                }
            }
            return nil
        }
    }

    private enum Keys {
        static let server = "com.voltaserve.server"
    }
}
