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
import VoltaserveCore

struct BrowserList: View, LoadStateProvider, ViewDataProvider, TimerLifecycle, TokenDistributing, ListItemScrollable {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var workspaceStore: WorkspaceStore
    @StateObject private var browserStore = BrowserStore()
    @State private var tappedItem: VOFile.Entity?
    @State private var searchText = ""
    private let folderID: String
    private let confirmLabelText: String?
    private let onCompletion: ((String) -> Void)?
    private let onDismiss: (() -> Void)?

    init(
        _ folderID: String,
        workspaceStore: WorkspaceStore,
        confirmLabelText: String?,
        onCompletion: ((String) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.folderID = folderID
        self.workspaceStore = workspaceStore
        self.confirmLabelText = confirmLabelText
        self.onCompletion = onCompletion
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let error {
                VOErrorMessage(error)
            } else {
                if let entities = browserStore.entities {
                    Group {
                        if entities.count == 0 {
                            Text("There are no items.")
                        } else {
                            List {
                                ForEach(entities, id: \.id) { file in
                                    NavigationLink {
                                        BrowserList(
                                            file.id,
                                            workspaceStore: workspaceStore,
                                            confirmLabelText: confirmLabelText,
                                            onCompletion: onCompletion
                                        )
                                        .navigationTitle(file.name)
                                    } label: {
                                        FileRow(file)
                                    }
                                    .onAppear {
                                        onListItemAppear(file.id)
                                    }
                                }
                            }
                            .listStyle(.inset)
                            .navigationDestination(item: $tappedItem) {
                                Viewer($0)
                            }
                        }
                    }
                    .refreshable {
                        browserStore.fetchNextPage(replace: true)
                    }
                    .searchable(text: $searchText)
                    .onChange(of: searchText) {
                        browserStore.searchPublisher.send($1)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(confirmLabelText ?? "Done") {
                    onCompletion?(folderID)
                }
            }
            if let workspace = workspaceStore.current, folderID == workspace.rootID {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                if browserStore.entitiesIsLoading {
                    ProgressView()
                }
            }
        }
        .onAppear {
            browserStore.folderID = folderID
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
        .onChange(of: browserStore.query) {
            browserStore.clear()
            browserStore.fetchNextPage()
        }
    }

    // MARK: - LoadStateProvider

    var isLoading: Bool {
        workspaceStore.entitiesIsLoadingFirstTime && browserStore.folderIsLoading
    }

    var error: String? {
        workspaceStore.entitiesError ?? browserStore.folderError
    }

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        browserStore.fetchFolder()
        browserStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        browserStore.startTimer()
    }

    func stopTimers() {
        browserStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        browserStore.token = token
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if browserStore.isEntityThreshold(id) {
            browserStore.fetchNextPage()
        }
    }
}
