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

public struct WorkspaceOverview: View, ViewDataProvider, LoadStateProvider {
    @EnvironmentObject private var sessionStore: SessionStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var shouldDismissSelf = false
    @State private var workspaceIsLoading = false
    private var id: String

    public init(_ id: String, workspaceStore: WorkspaceStore) {
        self.id = id
        self.workspaceStore = workspaceStore
    }

    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else if let current = workspaceStore.current {
                VStack {
                    VOAvatar(name: current.name, size: 100)
                        .padding()
                    Form {
                        NavigationLink {
                            if let root = workspaceStore.root {
                                FileOverview(root, workspaceStore: workspaceStore)
                                    .navigationTitle(current.name)
                            }
                        } label: {
                            Label("Browse", systemImage: "folder")
                        }
                        NavigationLink {
                            WorkspaceSettings(workspaceStore: workspaceStore, shouldDismissParent: $shouldDismissSelf)
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .modifierIf(workspaceStore.current != nil) {
            $0.navigationTitle(workspaceStore.current!.name)
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
        workspaceStore.currentIsLoading || workspaceStore.rootIsLoading
    }

    public var error: String? {
        workspaceStore.currentError ?? workspaceStore.rootError
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        workspaceStore.fetchCurrent(id: id)
        workspaceStore.fetchRoot()
    }
}
