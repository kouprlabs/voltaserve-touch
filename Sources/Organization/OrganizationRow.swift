import SwiftUI

struct OrganizationRow: View {
    var name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        HStack(spacing: 15) {
            Avatar(name: name, size: 45)
            Text(name)
        }
    }
}

#Preview {
    OrganizationRow("My Organization")
}
