import SwiftUI
import VoltaserveCore

struct SharingUserList: View {
    @EnvironmentObject private var sharingStore: SharingStore
    @State private var user: VOUser.Entity?
    @State private var permission: VOPermission.Value?
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            if let userPermissions = sharingStore.userPermissions {
                if userPermissions.isEmpty {
                    Text("Not shared with any users.")
                } else {
                    List(userPermissions, id: \.id) { userPermission in
                        NavigationLink {
                            SharingUserPermission(
                                files: [file],
                                fixedUser: userPermission.user,
                                defaultPermission: userPermission.permission
                            )
                        } label: {
                            SharingUserRow(userPermission)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}
