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

public struct SnapshotOverview: View, ErrorPresentable {
    @ObservedObject private var snapshotStore: SnapshotStore
    @Environment(\.dismiss) private var dismiss
    @State private var activateConfirmationIsPresentable = false
    @State private var detachConfirmationIsPresentable = false
    @State private var isActivating = false
    @State private var isDetaching = false
    private let snapshot: VOSnapshot.Entity

    public init(_ snapshot: VOSnapshot.Entity, snapshotStore: SnapshotStore) {
        self.snapshot = snapshot
        self.snapshotStore = snapshotStore
    }

    public var body: some View {
        Form {
            Section(header: VOSectionHeader("Properties")) {
                if let createTime = snapshot.createTime.date?.pretty {
                    HStack {
                        Text("Create Time")
                        Spacer()
                        Text(createTime)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundStyle(.secondary)
                    }
                }
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(snapshot.version)")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Size")
                    Spacer()
                    Text(snapshot.original.size.prettyBytes())
                }
                if let task = snapshot.task {
                    NavigationLink {
                        TaskOverview(task)
                    } label: {
                        Text("Task")
                    }
                }
            }
            if snapshot.hasCapabilities {
                Section(header: VOSectionHeader("Capabilities")) {
                    SnapshotCapabilities(snapshot)
                }
            }
            if !snapshot.isActive {
                Section(header: VOSectionHeader("Actions")) {
                    Button {
                        activateConfirmationIsPresentable = true
                    } label: {
                        HStack {
                            Text("Activate Snapshot")
                            if isActivating {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing)
                    .confirmationDialog("Activate Snapshot", isPresented: $activateConfirmationIsPresentable) {
                        Button("Activate Snapshot") {
                            performActivate()
                        }
                    } message: {
                        Text("Are you sure you want to activate this snapshot?")
                    }
                    Button(role: .destructive) {
                        detachConfirmationIsPresentable = true
                    } label: {
                        HStack {
                            Text("Detach Snapshot")
                            if isDetaching {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(snapshot.isActive || isProcessing)
                    .confirmationDialog("Detach Snapshot", isPresented: $detachConfirmationIsPresentable) {
                        Button("Detach Snapshot", role: .destructive) {
                            performDetach()
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to detach this snapshot?")
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("#\(snapshot.id)")
        .voErrorSheet(isPresented: $errorIsPresented, message: errorMessage)
    }

    private var isProcessing: Bool {
        isDetaching || isActivating
    }

    private func performActivate() {
        withErrorHandling {
            try await snapshotStore.activate(snapshot.id)
            return true
        } before: {
            isActivating = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isActivating = false
        }
    }

    private func performDetach() {
        withErrorHandling {
            try await snapshotStore.detach(snapshot.id)
            return true
        } before: {
            isDetaching = true
        } success: {
            dismiss()
        } failure: { message in
            errorMessage = message
            errorIsPresented = true
        } anyways: {
            isDetaching = true
        }
    }

    // MARK: - ErrorPresentable

    @State public var errorIsPresented = false
    @State public var errorMessage: String?
}
