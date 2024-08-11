import Foundation

struct PermissionData {
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
    }

    func gtViewerPermission(permission: Value) -> Bool {
        permission.weight() > Value.viewer.weight()
    }

    func gtEditorPermission(permission: Value) -> Bool {
        permission.weight() > Value.editor.weight()
    }

    func gtOwnerPermission(permission: Value) -> Bool {
        permission.weight() > Value.owner.weight()
    }

    func geViewerPermission(permission: Value) -> Bool {
        permission.weight() >= Value.viewer.weight()
    }

    func geEditorPermission(permission: Value) -> Bool {
        permission.weight() >= Value.editor.weight()
    }

    func geOwnerPermission(permission: Value) -> Bool {
        permission.weight() >= Value.owner.weight()
    }

    func ltViewerPermission(permission: Value) -> Bool {
        permission.weight() < Value.viewer.weight()
    }

    func ltEditorPermission(permission: Value) -> Bool {
        permission.weight() < Value.editor.weight()
    }

    func ltOwnerPermission(permission: Value) -> Bool {
        permission.weight() < Value.owner.weight()
    }

    func leViewerPermission(permission: Value) -> Bool {
        permission.weight() <= Value.viewer.weight()
    }

    func leEditorPermission(permission: Value) -> Bool {
        permission.weight() <= Value.editor.weight()
    }

    func leOwnerPermission(permission: Value) -> Bool {
        permission.weight() <= Value.owner.weight()
    }
}
