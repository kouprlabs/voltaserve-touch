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

public struct GroupOverview: View, ViewDataProvider, LoadStateProvider {
    @EnvironmentObject private var sessionStore: SessionStore
    @ObservedObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var shouldDismissSelf = false
    private let id: String

    public init(_ id: String, groupStore: GroupStore) {
        self.id = id
        self.groupStore = groupStore
    }

    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else if let current = groupStore.current {
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
                            GroupSettings(groupStore: groupStore, shouldDismissParent: $shouldDismissSelf)
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .modifierIf(groupStore.current != nil) {
            $0.navigationTitle(groupStore.current!.name)
        }
        .onAppear {
            onAppearOrChange()
        }
        .onChange(of: shouldDismissSelf) { _, newValue in
            if newValue {
                dismiss()
            }
        }
    }

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        groupStore.currentIsLoading
    }

    public var error: String? {
        groupStore.currentError
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        groupStore.fetchCurrent(id)
    }
}
