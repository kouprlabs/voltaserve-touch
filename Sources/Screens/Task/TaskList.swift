import SwiftUI

struct TaskList: View {
    @EnvironmentObject private var taskStore: TaskStore
    @EnvironmentObject private var tokenStore: TokenStore
    @Environment(\.dismiss) private var dismiss
    @State private var isDismissingAll = false

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
            isPresented: $taskStore.showError,
            title: taskStore.errorTitle,
            message: taskStore.errorMessage
        )
        .onAppear {
            taskStore.clear()
            if tokenStore.token != nil {
                onAppearOrChange()
            }
        }
        .onDisappear {
            stopTimers()
        }
        .onChange(of: tokenStore.token) { _, newToken in
            if newToken != nil {
                onAppearOrChange()
            }
        }
    }

    private func performDismissAll() {
        isDismissingAll = true
        withErrorHandling {
            try await taskStore.dismiss()
            return true
        } success: {
            taskStore.fetchList(replace: true)
        } failure: { message in
            taskStore.errorTitle = "Error: Dismissing All Tasks"
            taskStore.errorMessage = message
            taskStore.showError = true
        } anyways: {
            isDismissingAll = false
        }
    }

    private func onAppearOrChange() {
        fetchData()
        startTimers()
    }

    private func fetchData() {
        taskStore.fetchList()
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
}
