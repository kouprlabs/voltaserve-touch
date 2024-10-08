import SwiftUI
import VoltaserveCore

struct WorkspaceEditStorageCapacity: View {
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var value: Int?
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    init(workspaceStore: WorkspaceStore) {
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        if let current = workspaceStore.current {
            Form {
                VOStoragePicker(value: $value)
                    .disabled(isSaving)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Change Storage Capacity")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performSave()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                value = current.storageCapacity
            }
            .onChange(of: workspaceStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.storageCapacity
                }
            }
        } else {
            ProgressView()
        }
    }

    private func performSave() {
        guard let current = workspaceStore.current else { return }
        guard let value else { return }
        isSaving = true

        withErrorHandling {
            try await workspaceStore.patchStorageCapacity(current.id, storageCapacity: value)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Saving Storage Capacity"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let value, let current = workspaceStore.current {
            return value > 0 && current.storageCapacity != value
        }
        return false
    }
}
