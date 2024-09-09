import SwiftUI
import VoltaserveCore

struct WorkspaceEditName: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false

    var body: some View {
        if let current = workspaceStore.current {
            Form {
                Section(header: VOSectionHeader("Name")) {
                    TextField("Name", text: $value)
                        .disabled(isSaving)
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
                    Text("Change Name")
                        .font(.headline)
                }
            }
            .onAppear {
                value = current.name
            }
            .onChange(of: workspaceStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.name
                }
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        WorkspaceEditName()
            .environmentObject(WorkspaceStore(current: VOWorkspace.Entity.devInstance))
    }
}
