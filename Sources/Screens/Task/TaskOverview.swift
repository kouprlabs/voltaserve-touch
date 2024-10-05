import SwiftUI
import VoltaserveCore

struct TaskOverview: View {
    @EnvironmentObject private var taskStore: TaskStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDismissConfirmation = false
    @State private var showError = false
    @State private var isDismissing = false
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity) {
        self.task = task
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
                Section(header: VOSectionHeader("Actions")) {
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
            taskStore.errorTitle = "Error: Dismissing Task"
            taskStore.errorMessage = message
            taskStore.showError = true
        } anyways: {
            isDismissing = false
        }
    }
}

#Preview {
    NavigationView {
        TaskOverview(.init(
            id: "04WooxYQJJ83Q",
            name: "Deleting.",
            error: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            isIndeterminate: true,
            userID: UUID().uuidString,
            status: .error,
            payload: VOTask.Payload(object: "Choose-an-automation-tool-ebook-Red-Hat-Developer.pdf")
        ))
    }
    .environmentObject(TaskStore())
}

#Preview {
    NavigationView {
        TaskOverview(.init(
            id: "04WooxYQJJ83Q",
            name: "Measuring image dimensions.",
            isIndeterminate: true,
            userID: UUID().uuidString,
            status: .running,
            payload: VOTask.Payload(object: "human-freedom-index-2022.pdf")
        ))
    }
    .environmentObject(TaskStore())
}
