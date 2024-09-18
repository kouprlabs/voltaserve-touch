import SwiftUI
import VoltaserveCore

struct OrganizationSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var shouldDismiss: (() -> Void)?

    init(_ shouldDismiss: (() -> Void)? = nil) {
        self.shouldDismiss = shouldDismiss
    }

    var body: some View {
        if let organization = organizationStore.current {
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
            .alert("Delete Organization", isPresented: $showDelete) {
                Button("Delete Permanently", role: .destructive) {
                    performDelete()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this organization?")
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        } else {
            ProgressView()
        }
    }

    private func performDelete() {
        isDeleting = true
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            Task { @MainActor in
                isDeleting = false
                presentationMode.wrappedValue.dismiss()
                shouldDismiss?()
            }
        }
    }
}
