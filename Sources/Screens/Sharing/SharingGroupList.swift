import SwiftUI
import VoltaserveCore

struct SharingGroupList: View {
    @ObservedObject private var sharingStore: SharingStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    private let fileID: String

    init(_ fileID: String, sharingStore: SharingStore, workspaceStore: WorkspaceStore) {
        self.fileID = fileID
        self.sharingStore = sharingStore
        self.workspaceStore = workspaceStore
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
                                fileIDs: [fileID],
                                sharingStore: sharingStore,
                                workspaceStore: workspaceStore,
                                predefinedGroup: groupPermission.group,
                                defaultPermission: groupPermission.permission,
                                enableRevoke: true
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
