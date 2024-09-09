import SwiftUI
import Voltaserve

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
                        isSaving = true
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                            isSaving = false
                            presentationMode.wrappedValue.dismiss()
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
            .onAppear {
                value = current.name
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        OrganizationEditName()
            .environmentObject(OrganizationStore(VOOrganization.Entity.devInstance))
    }
}
