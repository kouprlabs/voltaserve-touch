import SwiftUI
import VoltaserveCore

struct OrganizationEditName: View {
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false

    var body: some View {
        if let current = organizationStore.current {
            Form {
                Section(header: VOSectionHeader("Name")) {
                    TextField("Name", text: $value)
                        .disabled(isSaving)
                }
                Section {
                    Button {
                        performSave()
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
            .onChange(of: organizationStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.name
                }
            }
        } else {
            ProgressView()
        }
    }

    private func performSave() {
        isSaving = true
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            presentationMode.wrappedValue.dismiss()
            isSaving = false
        }
    }
}

#Preview {
    OrganizationEditName()
        .environmentObject(OrganizationStore(VOOrganization.Entity.devInstance))
}
