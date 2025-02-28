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

struct TaskList: View, ViewDataProvider, LoadStateProvider, TimerLifecycle, TokenDistributing, ListItemScrollable,
    ErrorPresentable
{
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var taskStore = TaskStore()
    @Environment(\.dismiss) private var dismiss
    @State private var isDismissingAll = false

    var body: some View {
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

    var isLoading: Bool {
        taskStore.entitiesIsLoadingFirstTime
    }

    var error: String? {
        taskStore.entitiesError
    }

    // MARK: - ErrorPresentable

    @State var errorIsPresented: Bool = false
    @State var errorMessage: String?

    // MARK: - ViewDataProvider

    func onAppearOrChange() {
        fetchData()
    }

    func fetchData() {
        taskStore.fetchNextPage(replace: true)
    }

    // MARK: - TimerLifecycle

    func startTimers() {
        taskStore.startTimer()
    }

    func stopTimers() {
        taskStore.stopTimer()
    }

    // MARK: - TokenDistributing

    func assignTokenToStores(_ token: VOToken.Value) {
        taskStore.token = token
    }

    // MARK: - ListItemScrollable

    func onListItemAppear(_ id: String) {
        if taskStore.isEntityThreshold(id) {
            taskStore.fetchNextPage()
        }
    }
}
