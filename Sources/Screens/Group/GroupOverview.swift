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

struct GroupOverview: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    private let group: VOGroup.Entity

    init(_ group: VOGroup.Entity, groupStore: GroupStore) {
        self.group = group
        self.groupStore = groupStore
    }

    var body: some View {
        VStack {
            if let current = groupStore.current {
                VStack {
                    VOAvatar(name: current.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            GroupMemberList(groupStore: groupStore)
                        } label: {
                            Label("Members", systemImage: "person.2")
                        }
                        NavigationLink {
                            GroupSettings(groupStore: groupStore) {
                                dismiss()
                            }
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(group.name)
        .onAppear {
            groupStore.current = group
        }
    }
}
