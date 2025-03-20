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

public struct TaskRow: View {
    @Environment(\.colorScheme) private var colorScheme
    private let task: VOTask.Entity
    private let enableSpacer: Bool

    public init(_ task: VOTask.Entity, enableSpacer: Bool = true) {
        self.task = task
        self.enableSpacer = enableSpacer
    }

    public var body: some View {
        VStack {
            HStack(spacing: VOMetrics.spacingSm) {
                if task.status == .running, task.isIndeterminate {
                    if #available(iOS 18.0, macOS 15.0, *) {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle")
                            .symbolEffect(.rotate, options: .repeat(.continuous))
                            .font(.title2)
                            .foregroundStyle(Color.blue400)
                    }
                } else if task.status == .waiting {
                    Image(systemName: "hourglass.circle")
                        .font(.title2)
                        .foregroundStyle(Color.gray400)
                } else if task.status == .success {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundStyle(Color.green400)
                } else if task.status == .error {
                    Image(systemName: "exclamationmark.circle")
                        .font(.title2)
                        .foregroundStyle(Color.red400)
                }
                if let object = task.payload?.object {
                    VStack(alignment: .leading) {
                        Text(object)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Text(task.name)
                            .font(.footnote)
                            .foregroundStyle(Color.gray500)
                            .lineLimit(3)
                            .truncationMode(.tail)
                        Text(task.createTime.relativeDate())
                            .font(.footnote)
                            .foregroundStyle(Color.gray500)
                    }
                } else {
                    VStack(alignment: .leading) {
                        Text(task.name)
                            .font(.footnote)
                            .foregroundStyle(Color.gray500)
                            .lineLimit(3)
                            .truncationMode(.tail)
                        Text(task.createTime.relativeDate())
                            .font(.footnote)
                            .foregroundStyle(Color.gray500)
                    }
                }
                if enableSpacer {
                    Spacer()
                }
            }
            if task.status == .running, !task.isIndeterminate {
                ProgressView(value: CGFloat(task.percentage ?? 0), total: 100)
                    .progressViewStyle(.linear)
                    .tint(colorScheme == .dark ? .white : .black)
            }
        }
    }
}

#Preview {
    NavigationStack {
        Form {
            List {
                NavigationLink(destination: Color.clear) {
                    TaskRow(
                        .init(
                            id: UUID().uuidString,
                            name: "Measuring image dimensions.",
                            isIndeterminate: true,
                            userID: UUID().uuidString,
                            status: .running,
                            isDismissible: false,
                            payload: VOTask.Payload(object: "human-freedom-index-2022.pdf"),
                            createTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-5 * 60))
                        ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(
                        .init(
                            id: UUID().uuidString,
                            name: "Waiting.",
                            isIndeterminate: true,
                            userID: UUID().uuidString,
                            status: .waiting,
                            isDismissible: false,
                            payload: VOTask.Payload(object: "Kubernetes-Patterns-2nd-Edition.pdf"),
                            createTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-60 * 60))
                        ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(
                        .init(
                            id: UUID().uuidString,
                            name: "Creating thumbnail.",
                            isIndeterminate: true,
                            userID: UUID().uuidString,
                            status: .success,
                            isDismissible: true,
                            payload: VOTask.Payload(object: "In_the_Conservatory.tiff"),
                            createTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-2 * 60 * 60))

                        ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(
                        .init(
                            id: UUID().uuidString,
                            name: "Deleting.",
                            error: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                            isIndeterminate: true,
                            userID: UUID().uuidString,
                            status: .error,
                            isDismissible: true,
                            payload: VOTask.Payload(object: "Choose-an-automation-tool-ebook-Red-Hat-Developer.pdf"),
                            createTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3 * 60 * 60))
                        ))
                }
                NavigationLink(destination: Color.clear) {
                    TaskRow(
                        .init(
                            id: UUID().uuidString,
                            name: "Collecting insights.",
                            percentage: 50,
                            isIndeterminate: false,
                            userID: UUID().uuidString,
                            status: .running,
                            isDismissible: false,
                            payload: VOTask.Payload(object: "Introducing the Arm architecture.pdf"),
                            createTime: ISO8601DateFormatter().string(from: Date().addingTimeInterval(-4 * 60 * 60))
                        ))
                }
            }
        }
    }
}
