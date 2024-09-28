import SwiftUI
import VoltaserveCore

struct SharingGroupList: View {
    @EnvironmentObject private var sharingStore: SharingStore
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if let groupPermissions = sharingStore.groupPermissions {
                if groupPermissions.isEmpty {
                    Text("Not shared with any groups.")
                } else {
                    List(groupPermissions, id: \.id) { groupPermission in
                        NavigationLink {
                            SharingGroupPermission(
                                files: [file],
                                fixedGroup: groupPermission.group,
                                defaultPermission: groupPermission.permission
                            )
                        } label: {
                            SharingGroupRow(groupPermission)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}
