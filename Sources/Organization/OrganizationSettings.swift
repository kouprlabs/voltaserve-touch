import SwiftUI
import VoltaserveCore

struct OrganizationSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var shouldDismiss: (() -> Void)?

    init(_ shouldDismiss: (() -> Void)? = nil) {
        self.shouldDismiss = shouldDismiss
    }

    var body: some View {
        NavigationView {
            if let organization = organizationStore.current {
                VStack {
                    VOAvatar(name: organization.name, size: 100)
                        .padding()
                    Form {
                        Section(header: VOSectionHeader("Basics")) {
                            NavigationLink(destination: OrganizationEditName()) {
                                HStack {
                                    Text("Name")
                                    Spacer()
                                    Text(organization.name)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(isDeleting)
                        }
                        Section(header: VOSectionHeader("Advanced")) {
                            Button(role: .destructive) {
                                showDelete = true
                            } label: {
                                HStack {
                                    Text("Delete Organization")
                                    if isDeleting {
                                        Spacer()
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(isDeleting)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Settings")
                            .font(.headline)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .disabled(isDeleting)
                    }
                }
                .alert("Delete Organization", isPresented: $showDelete) {
                    Button("Delete Permanently", role: .destructive) {
                        isDeleting = true
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                            Task { @MainActor in
                                isDeleting = false
                                presentationMode.wrappedValue.dismiss()
                                shouldDismiss?()
                            }
                        }
                    }
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
