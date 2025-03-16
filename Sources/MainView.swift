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

struct MainView: View {
    @State private var selection: TabType = .murph

    enum TabType {
        case murph
        case workspaces
        case groups
        case organizations
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Murph", systemImage: "message", value: TabType.murph) {
                MurphOverview()
            }
            Tab("Workspaces", systemImage: "internaldrive", value: TabType.workspaces) {
                WorkspaceList()
            }
            Tab("Groups", systemImage: "person.2.fill", value: TabType.groups) {
                GroupList()
            }
            Tab("Organizations", systemImage: "flag", value: TabType.organizations) {
                OrganizationList()
            }
        }
    }
}
