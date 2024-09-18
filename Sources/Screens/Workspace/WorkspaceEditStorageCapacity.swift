import SwiftUI
import VoltaserveCore

struct WorkspaceEditStorageCapacity: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value: Int?
    @State private var unit: StorageUnit?
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        if let current = workspaceStore.current {
            Form {
                Section(header: VOSectionHeader("Storage Capacity")) {
                    TextField(
                        "Storage Capacity",
                        value: Binding<Int>(
                            get: {
                                if let value {
                                    return value.convertFromByte(unit: value.storageUnit)
                                }
                                return value ?? 0
                            },
                            set: {
                                value = Int($0).normalizeToByte(unit: unit ?? .b)
                            }
                        ),
                        formatter: NumberFormatter()
                    ).disabled(isSaving)
                        .onChange(of: value) { _, newCapacity in
                            if let newCapacity {
                                unit = newCapacity.storageUnit
                            }
                        }
                    Picker("Unit", selection: $unit) {
                        Text("B").tag(StorageUnit.b)
                        Text("MB").tag(StorageUnit.mb)
                        Text("GB").tag(StorageUnit.gb)
                        Text("TB").tag(StorageUnit.tb)
                    }
                    .disabled(isSaving)
                    .onChange(of: unit) { _, newUnit in
                        if let newUnit, let value {
                            let visibleCapacity = value.convertFromByte(unit: value.storageUnit)
                            self.value = visibleCapacity.normalizeToByte(unit: newUnit)
                        }
                    }
                }
                Section {
                    Button {
                        performSave()
                    } label: {
                        HStack {
                            Text("Save Storage Capacity")
                            if isSaving {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSaving || !isValid())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Change Storage Capacity")
                        .font(.headline)
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

        VOErrorResponse.withErrorHandling {
            try await workspaceStore.patchStorageCapacity(current.id, storageCapacity: value)
        } success: {
            presentationMode.wrappedValue.dismiss()
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
