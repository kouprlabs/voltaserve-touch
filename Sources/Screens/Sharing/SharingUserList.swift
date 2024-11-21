// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI
import VoltaserveCore

struct SharingUserList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var sharingStore: SharingStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @StateObject private var userStore = UserStore()
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
                            SharingUserRow(
                                userPermission,
                                userPictureURL: userStore.urlForPicture(
                                    userPermission.user.id,
                                    fileExtension: userPermission.user.picture?.fileExtension
                                )
                            )
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if let workspace = workspaceStore.current {
                userStore.organizationID = workspace.organization.id
            }
            if let token = tokenStore.token {
                assignTokenToStores(token)
            }
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
            }
        }
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        userStore.token = token
    }
}
