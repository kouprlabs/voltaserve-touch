import SwiftUI
import Voltaserve

struct OrganizationSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            if let organization = organizationStore.current {
                VStack {
                    VOAvatar(name: organization.name, size: 100)
                    Form {
                        Section(header: VOSectionHeader("Basics")) {
                            NavigationLink(destination: Text("Change Name")) {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    Text(organization.name)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: VOSectionHeader("Advanced")) {
                            Button("Delete Organization", role: .destructive) {
                                showDelete = true
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .alert("Delete Organization", isPresented: $showDelete) {
                    Button("Delete Permanently", role: .destructive) {}
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure you would like to delete this organization?")
                }
                .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
                    Button(VOTextConstants.errorAlertButtonLabel) {}
                } message: {
                    if let errorMessage {
                        Text(errorMessage)
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    OrganizationSettings()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(OrganizationStore(VOOrganization.Entity.devInstance))
}
