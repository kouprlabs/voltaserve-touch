import Foundation

struct PermissionModel {
    enum PermissionType: String, Decodable {
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

    func gtViewerPermission(permission: PermissionType) -> Bool {
        permission.weight() > PermissionType.viewer.weight()
    }

    func gtEditorPermission(permission: PermissionType) -> Bool {
        permission.weight() > PermissionType.editor.weight()
    }

    func gtOwnerPermission(permission: PermissionType) -> Bool {
        permission.weight() > PermissionType.owner.weight()
    }

    func geViewerPermission(permission: PermissionType) -> Bool {
        permission.weight() >= PermissionType.viewer.weight()
    }

    func geEditorPermission(permission: PermissionType) -> Bool {
        permission.weight() >= PermissionType.editor.weight()
    }

    func geOwnerPermission(permission: PermissionType) -> Bool {
        permission.weight() >= PermissionType.owner.weight()
    }

    func ltViewerPermission(permission: PermissionType) -> Bool {
        permission.weight() < PermissionType.viewer.weight()
    }

    func ltEditorPermission(permission: PermissionType) -> Bool {
        permission.weight() < PermissionType.editor.weight()
    }

    func ltOwnerPermission(permission: PermissionType) -> Bool {
        permission.weight() < PermissionType.owner.weight()
    }

    func leViewerPermission(permission: PermissionType) -> Bool {
        permission.weight() <= PermissionType.viewer.weight()
    }

    func leEditorPermission(permission: PermissionType) -> Bool {
        permission.weight() <= PermissionType.editor.weight()
    }

    func leOwnerPermission(permission: PermissionType) -> Bool {
        permission.weight() <= PermissionType.owner.weight()
    }
}
