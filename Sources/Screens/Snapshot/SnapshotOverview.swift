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

struct SnapshotOverview: View {
    @ObservedObject private var snapshotStore: SnapshotStore
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var showActivateConfirmation = false
    @State private var showDetachConfirmation = false
    @State private var isActivating = false
    @State private var isDetaching = false
    private let snapshot: VOSnapshot.Entity

    init(_ snapshot: VOSnapshot.Entity, snapshotStore: SnapshotStore) {
        self.snapshot = snapshot
        self.snapshotStore = snapshotStore
    }

    var body: some View {
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
                if let size = snapshot.original.size {
                    HStack {
                        Text("Size")
                        Spacer()
                        Text(size.prettyBytes())
                    }
                }
                HStack {
                    Text("Status")
                    Spacer()
                    SnapshotStatus(snapshot.status)
                }
            }
            if snapshot.hasFeatures() {
                Section(header: VOSectionHeader("Features")) {
                    SnapshotFeatures(snapshot)
                }
            }
            if !snapshot.isActive {
                Section(header: VOSectionHeader("Actions")) {
                    Button {
                        showActivateConfirmation = true
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
                    .confirmationDialog("Activate Snapshot", isPresented: $showActivateConfirmation)
                    {
                        Button("Activate") {
                            performActivate()
                        }
                    } message: {
                        Text("Are you sure you want to activate this snapshot?")
                    }
                    Button(role: .destructive) {
                        showDetachConfirmation = true
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
                    .confirmationDialog("Detach Snapshot", isPresented: $showDetachConfirmation) {
                        Button("Detach", role: .destructive) {
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
        .voErrorAlert(
            isPresented: $showError,
            title: snapshotStore.errorTitle,
            message: snapshotStore.errorMessage
        )
        .sync($snapshotStore.showError, with: $showError)
    }

    private var isProcessing: Bool {
        isDetaching || isActivating
    }

    private func performActivate() {
        isActivating = true
        withErrorHandling {
            try await snapshotStore.activate(snapshot.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Activating Snapshot"
            errorMessage = message
            showError = true
        } anyways: {
            isActivating = false
        }
    }

    private func performDetach() {
        isDetaching = true
        withErrorHandling {
            try await snapshotStore.detach(snapshot.id)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Detaching Snapshot"
            errorMessage = message
            showError = true
        } anyways: {
            isDetaching = true
        }
    }
}
