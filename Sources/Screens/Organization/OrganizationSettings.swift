import SwiftUI
import VoltaserveCore

struct OrganizationSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var onCompletion: (() -> Void)?

    init(_ onCompletion: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
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
        guard let current = organizationStore.current else { return }

        isDeleting = true

        VOErrorResponse.withErrorHandling {
            try await organizationStore.delete(current.id)
            return true
        } success: {
            dismiss()
            onCompletion?()
        } failure: { message in
            errorTitle = "Error: Deleting Organization"
            errorMessage = message
            showError = true
        } anyways: {
            isDeleting = false
        }
    }
}
