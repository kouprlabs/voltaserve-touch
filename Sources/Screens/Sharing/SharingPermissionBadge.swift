import SwiftUI
import VoltaserveCore

struct SharingPermissionBadge: View {
    var permission: VOPermission.Value

    init(_ permission: VOPermission.Value) {
        self.permission = permission
    }

    var body: some View {
        Text(text())
            .font(.footnote)
            .padding(.horizontal)
            .frame(height: 20)
            .foregroundStyle(Constants.background.textColor())
            .background(Constants.background)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    func text() -> String {
        switch permission {
        case .viewer:
            "Viewer"
        case .editor:
            "Editor"
        case .owner:
            "Owner"
        case .none:
            "None"
        }
    }

    private enum Constants {
        static let background = Color.gray300
    }
}

#Preview {
    VStack {
        SharingPermissionBadge(.viewer)
        SharingPermissionBadge(.editor)
        SharingPermissionBadge(.owner)
    }
}
