import SwiftUI
import VoltaserveCore

struct TaskList: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @StateObject private var taskStore = TaskStore()
    @Environment(\.dismiss) private var dismiss
    @State private var isDismissingAll = false
    @State private var showError = false

    var body: some View {
        NavigationStack {
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
                            if taskStore.isLoading {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
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
            } else {
                ProgressView()
            }
        }
        .voErrorAlert(
            isPresented: $showError,
            title: taskStore.errorTitle,
            message: taskStore.errorMessage
        )
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
        .sync($taskStore.showError, with: $showError)
        .environmentObject(taskStore)
    }

    private func onAppearOrChange() {
        fetchData()
    }

    private func fetchData() {
        taskStore.fetchList(replace: true)
    }

    private func assignTokenToStores(_ token: VOToken.Value) {
        taskStore.token = token
    }

    private func startTimers() {
        taskStore.startTimer()
    }

    private func stopTimers() {
        taskStore.stopTimer()
    }

    private func onListItemAppear(_ id: String) {
        if taskStore.isLast(id) {
            taskStore.fetchList()
        }
    }

    private func performDismissAll() {
        isDismissingAll = true
        withErrorHandling {
            try await taskStore.dismiss()
            return true
        } success: {
            taskStore.fetchList(replace: true)
            dismiss()
        } failure: { message in
            taskStore.errorTitle = "Error: Dismissing All Tasks"
            taskStore.errorMessage = message
            taskStore.showError = true
        } anyways: {
            isDismissingAll = false
        }
    }
}
