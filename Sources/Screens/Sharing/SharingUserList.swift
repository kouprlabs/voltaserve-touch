import SwiftUI
import VoltaserveCore

struct SharingUserList: View {
    @ObservedObject private var sharingStore: SharingStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var user: VOUser.Entity?
    @State private var permission: VOPermission.Value?
    private let fileID: String

    init(_ fileID: String, sharingStore: SharingStore, workspaceStore: WorkspaceStore) {
        self.fileID = fileID
        self.sharingStore = sharingStore
        self.workspaceStore = workspaceStore
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
                                fileIDs: [fileID],
                                sharingStore: sharingStore,
                                workspaceStore: workspaceStore,
                                predefinedUser: userPermission.user,
                                defaultPermission: userPermission.permission,
                                enableRevoke: true
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
