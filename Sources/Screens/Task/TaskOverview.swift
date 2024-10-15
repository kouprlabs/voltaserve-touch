import SwiftUI
import VoltaserveCore

struct TaskOverview: View {
    @ObservedObject private var taskStore: TaskStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDismissConfirmation = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDismissing = false
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity, taskStore: TaskStore) {
        self.task = task
        self.taskStore = taskStore
    }

    var body: some View {
        Form {
            if let object = task.payload?.object {
                Section(header: VOSectionHeader("Payload")) {
                    Text(object)
                }
            }
            Section(header: VOSectionHeader("Name")) {
                Text(task.name)
            }
            Section(header: VOSectionHeader("Status")) {
                TaskStatusBadge(task.status)
            }
            if task.status == .error, let error = task.error {
                Section(header: VOSectionHeader("Error")) {
                    Text(error)
                }
            }
            if task.status == .error {
                Section {
                    Button(role: .destructive) {
                        showDismissConfirmation = true
                    } label: {
                        HStack {
                            Text("Dismiss Task")
                            if isDismissing {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isDismissing)
                    .confirmationDialog(
                        "Dismiss Task",
                        isPresented: $showDismissConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Dismiss", role: .destructive) {
                            performDismiss()
                        }
                    } message: {
                        Text("Are you sure you want to dismiss this task?")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("#\(task.id)")
        .voErrorAlert(
            isPresented: $showError,
            title: taskStore.errorTitle,
            message: taskStore.errorMessage
        )
        .sync($taskStore.showError, with: $showError)
    }

    private func performDismiss() {
        isDismissing = true
        withErrorHandling {
            try await taskStore.dismiss(task.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Dismissing Task"
            errorMessage = message
            showError = true
        } anyways: {
            isDismissing = false
        }
    }
}
