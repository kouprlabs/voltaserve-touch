import SwiftUI
import VoltaserveCore

struct SnapshotOverview: View {
    @ObservedObject private var snapshotStore: SnapshotStore
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
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
            Section(header: VOSectionHeader("Create Time")) {
                Text(snapshot.createTime)
            }
            Section(header: VOSectionHeader("Version")) {
                Text("\(snapshot.version)")
            }
            if snapshot.hasFeatures() {
                Section(header: VOSectionHeader("Features")) {
                    SnapshotFeatures(snapshot)
                }
            }
            Section(header: VOSectionHeader("Status")) {
                SnapshotStatus(snapshot.status)
            }
            if !snapshot.isActive {
                Section {
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
                    .confirmationDialog("Activate Snapshot", isPresented: $showActivateConfirmation) {
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
            snapshotStore.errorTitle = "Error: Activating Snapshot"
            snapshotStore.errorMessage = message
            snapshotStore.showError = true
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
            snapshotStore.errorTitle = "Error: Detaching Snapshot"
            snapshotStore.errorMessage = message
            snapshotStore.showError = true
        } anyways: {
            isDetaching = true
        }
    }
}
