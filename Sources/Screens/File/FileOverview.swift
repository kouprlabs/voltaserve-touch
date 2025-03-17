// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import Combine
import SwiftUI
import UIKit

public struct FileOverview: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var fileStore = FileStore()
    @ObservedObject private var workspaceStore: WorkspaceStore
    @State private var searchText = ""
    private let file: VOFile.Entity

    public init(_ file: VOFile.Entity, workspaceStore: WorkspaceStore) {
        self.file = file
        self.workspaceStore = workspaceStore
    }

    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = fileStore.entities {
                    Group {
                        if entities.count == 0 {
                            Text("There are no items.")
                        } else {
                            if fileStore.viewMode == .list {
                                FileList(fileStore: fileStore, workspaceStore: workspaceStore)
                            } else if fileStore.viewMode == .grid {
                                FileGrid(fileStore: fileStore, workspaceStore: workspaceStore)
                            }
                        }
                    }
                    .refreshable {
                        fileStore.fetchNextPage(replace: true)
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) {
                        fileStore.searchPublisher.send($1)
                    }
                }
            }
        }
        .fileSheets(fileStore: fileStore, workspaceStore: workspaceStore)
        .fileToolbar(fileStore: fileStore)
        .onAppear {
            fileStore.file = file
            fileStore.loadViewModeFromUserDefaults()
            if let token = tokenStore.token {
                assignTokenToStores(token)
                startTimers()
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                onAppearOrChange()
            }
        }
        .onChange(of: fileStore.query) {
            fileStore.clear()
            fileStore.fetchNextPage(replace: true)
        }
    }

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        fileStore.entitiesIsLoadingFirstTime || fileStore.fileIsLoading || fileStore.taskCountIsLoading
    }

    public var error: String? {
        fileStore.entitiesError ?? fileStore.fileError ?? fileStore.taskCountError
    }

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        fileStore.fetchFile()
        fileStore.fetchNextPage(replace: true)
        fileStore.fetchTaskCount()
    }

    // MARK: - TimerLifecycle

    public func startTimers() {
        fileStore.startTimer()
    }

    public func stopTimers() {
        fileStore.stopTimer()
    }

    // MARK: - TokenDistributing

    public func assignTokenToStores(_ token: VOToken.Value) {
        fileStore.token = token
    }
}
