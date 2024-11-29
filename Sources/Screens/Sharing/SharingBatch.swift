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

struct SharingBatch: View, TokenDistributing {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var sharingStore = SharingStore()
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var selection: Tag = .users
    @State private var user: VOUser.Entity?
    @State private var group: VOGroup.Entity?
    @State private var permission: VOPermission.Value?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    private let fileIDs: [String]

    init(_ files: [String], workspaceStore: WorkspaceStore) {
        fileIDs = files
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Users", systemImage: "person", value: Tag.users) {
                NavigationStack {
                    SharingUserPermission(
                        fileIDs: fileIDs,
                        sharingStore: sharingStore,
                        workspaceStore: workspaceStore,
                        enableCancel: true
                    )
                }
            }
            Tab("Groups", systemImage: "person.2", value: Tag.groups) {
                NavigationStack {
                    SharingGroupPermission(
                        fileIDs: fileIDs,
                        sharingStore: sharingStore,
                        workspaceStore: workspaceStore,
                        enableCancel: true
                    )
                }
            }
        }
        .onAppear {
            if let token = tokenStore.token {
                assignTokenToStores(token)
            }
        }
    }

    enum Tag {
        case users
        case groups
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        sharingStore.token = token
    }
}
