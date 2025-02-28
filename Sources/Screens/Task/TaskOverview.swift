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

struct TaskOverview: View, ErrorPresentable {
    @ObservedObject private var taskStore: TaskStore
    @ObservedObject private var fileStore: FileStore
    @Environment(\.dismiss) private var dismiss
    @State private var dismissConfirmationIsPresented = false
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
                        dismissConfirmationIsPresented = true
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
                        isPresented: $dismissConfirmationIsPresented,
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
            Section(header: VOSectionHeader("Time")) {
                if let createTime = task.createTime.date?.pretty {
                    HStack {
                        Text("Create time")
                        Spacer()
                        Text(createTime)
                            .foregroundStyle(.secondary)
                    }
                }
                if let updateTime = task.updateTime?.date?.pretty {
                    HStack {
                        Text("Update time")
                        Spacer()
                        Text(updateTime)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("#\(task.id)")
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private func performDismiss() {
        withErrorHandling {
            try await taskStore.dismiss(task.id)
            return true
        } before: {
            isDismissing = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isDismissing = false
        }
    }

    // MARK: - ErrorPresentable

    @State var errorIsPresented: Bool = false
    @State var errorMessage: String?
}
