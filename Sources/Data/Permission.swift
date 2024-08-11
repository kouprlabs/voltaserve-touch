import Foundation

enum Permission {
    enum Value: String, Decodable {
        case viewer
        case editor
        case owner

        func weight() -> Int {
            switch self {
            case .viewer:
                1
            case .editor:
                2
            case .owner:
                3
            }
        }

        func gt(_ permission: Value) -> Bool {
            weight() > permission.weight()
        }

        func ge(_ permission: Value) -> Bool {
            weight() >= permission.weight()
        }

        func lt(_ permission: Value) -> Bool {
            weight() < permission.weight()
        }

        func le(_ permission: Value) -> Bool {
            weight() <= permission.weight()
        }

        func eq(_ permission: Value) -> Bool {
            weight() == permission.weight()
        }
    }
}
