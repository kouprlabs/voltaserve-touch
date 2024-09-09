import SwiftUI
import Voltaserve

struct WorkspaceEditStorageCapacity: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var capacity: Int?
    @State private var unit: StorageUnit?
    @State private var isSaving = false

    var body: some View {
        if let current = workspaceStore.current {
            Form {
                Section(header: VOSectionHeader("Storage Capacity")) {
                    TextField(
                        "Storage Capacity",
                        value: Binding<Int>(
                            get: {
                                if let capacity {
                                    return capacity.convertFromByte(unit: capacity.storageUnit)
                                }
                                return capacity ?? 0
                            },
                            set: {
                                capacity = Int($0).normalizeToByte(unit: unit ?? .b)
                            }
                        ),
                        formatter: NumberFormatter()
                    ).disabled(isSaving)
                        .onChange(of: capacity) { _, newCapacity in
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
                        if let newUnit, let capacity {
                            let visibleCapacity = capacity.convertFromByte(unit: capacity.storageUnit)
                            self.capacity = visibleCapacity.normalizeToByte(unit: newUnit)
                        }
                    }
                }
                Section {
                    Button {
                        isSaving = true
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                            Task { @MainActor in
                                presentationMode.wrappedValue.dismiss()
                                isSaving = false
                            }
                        }
                    } label: {
                        HStack {
                            Text("Save")
                            if isSaving {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSaving)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Change Storage Capacity")
                        .font(.headline)
                }
            }
            .onAppear {
                capacity = current.storageCapacity
            }
            .onChange(of: workspaceStore.current) { _, newCurrent in
                if let newCurrent {
                    capacity = newCurrent.storageCapacity
                }
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        WorkspaceEditStorageCapacity()
            .environmentObject(WorkspaceStore(current: VOWorkspace.Entity.devInstance))
    }
}
