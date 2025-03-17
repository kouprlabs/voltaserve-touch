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

public struct TaskList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing,
    ListItemScrollable,
    ErrorPresentable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var taskStore = TaskStore()
    @Environment(\.dismiss) private var dismiss
    @State private var isDismissingAll = false

    public var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView()
                } else if let error {
                    VOErrorMessage(error)
                } else {
                    if let entities = taskStore.entities {
                        Group {
                            if entities.count == 0 {
                                Text("There are no tasks.")
                            } else {
                                List {
                                    ForEach(entities, id: \.id) { task in
                                        NavigationLink {
                                            TaskOverview(task)
                                        } label: {
                                            TaskRow(task)
                                                .onAppear {
                                                    onListItemAppear(task.id)
                                                }
                                        }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            taskStore.fetchNextPage(replace: true)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isDismissingAll {
                        ProgressView()
                    } else {
                        Button("Dismiss All") {
                            performDismissAll()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
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
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performDismissAll() {
        withErrorHandling {
            _ = try await taskStore.dismiss()
            return true
        } before: {
            isDismissingAll = true
        } success: {
            taskStore.fetchNextPage(replace: true)
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isDismissingAll = false
        }
    }

    // MARK: - LoadStateProvider

    public var isLoading: Bool {
        taskStore.entitiesIsLoadingFirstTime
    }

    public var error: String? {
        taskStore.entitiesError
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented: Bool = false
    @State public var errorMessage: String?

    // MARK: - ViewDataProvider

    public func onAppearOrChange() {
        fetchData()
    }

    public func fetchData() {
        taskStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    public func startTimers() {
        taskStore.startTimer()
    }

    public func stopTimers() {
        taskStore.stopTimer()
    }

    // MARK: - TokenDistributing

    public func assignTokenToStores(_ token: VOToken.Value) {
        taskStore.token = token
    }

    // MARK: - ListItemScrollable

    public func onListItemAppear(_ id: String) {
        if taskStore.isEntityThreshold(id) {
            taskStore.fetchNextPage()
        }
    }
}
