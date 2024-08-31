import Foundation

extension String {
    func stripBase64Prefix() -> String {
        guard hasPrefix("data:image/") else { return self }
        return String(split(separator: ",").last!)
    }
}
