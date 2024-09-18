import SwiftUI
import VoltaserveCore

struct GroupEditName: View {
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false

    var body: some View {
        if let current = groupStore.current {
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
            .onAppear {
                value = current.name
            }
            .onChange(of: groupStore.current) { _, newCurrent in
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
            Task { @MainActor in
                presentationMode.wrappedValue.dismiss()
                isSaving = false
            }
        }
    }
}

#Preview {
    GroupEditName()
        .environmentObject(GroupStore(VOGroup.Entity.devInstance))
}
