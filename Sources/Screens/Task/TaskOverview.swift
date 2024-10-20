import SwiftUI
import VoltaserveCore

struct TaskOverview: View {
    @ObservedObject private var taskStore: TaskStore
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDismissConfirmation = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDismissing = false
    private let task: VOTask.Entity

    init(_ task: VOTask.Entity, taskStore: TaskStore, fileStore: FileStore) {
        self.task = task
        self.taskStore = taskStore
        self.fileStore = fileStore
    }

    var body: some View {
        Form {
            Section(header: VOSectionHeader("Properties")) {
                if let object = task.payload?.object {
                    NavigationLink {
                        Form {
                            Text(object)
                        }
                        .navigationTitle("Payload")
                    } label: {
                        HStack {
                            Text("Payload")
                            Spacer()
                            Text(object)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                NavigationLink {
                    Form {
                        Text(task.name)
                    }
                    .navigationTitle("Name")
                } label: {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(task.name)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack {
                    Text("Status")
                    Spacer()
                    TaskStatusBadge(task.status)
                }
                if task.status == .error, let error = task.error {
                    NavigationLink {
                        Form {
                            Text(error)
                        }
                        .navigationTitle("Error")
                    } label: {
                        Text("Error")
                        Spacer()
                        Text(error)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                    }
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
            fileStore.fetchTaskCount()
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
