import SwiftUI
import VoltaserveCore

struct SharingGroupList: View {
    @ObservedObject private var sharingStore: SharingStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity, sharingStore: SharingStore, workspaceStore: WorkspaceStore) {
        self.file = file
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
                                files: [file],
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
