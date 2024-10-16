import SwiftUI
import VoltaserveCore

struct OrganizationSettings: View {
    @EnvironmentObject private var tokenStore: TokenStore
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?
    @State private var isDeleting = false
    private var onCompletion: (() -> Void)?

    init(organizationStore: OrganizationStore, onCompletion: (() -> Void)? = nil) {
        self.organizationStore = organizationStore
        self.onCompletion = onCompletion
    }

    var body: some View {
        Group {
            if let organization = organizationStore.current {
                Form {
                    Section(header: VOSectionHeader("Basics")) {
                        NavigationLink(destination: OrganizationEditName(organizationStore: organizationStore)) {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(organization.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(isDeleting)
                    }
                    Section(header: VOSectionHeader("Advanced")) {
                        Button(role: .destructive) {
                            showDeleteConfirmation = true
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
                        .confirmationDialog("Delete Organization", isPresented: $showDeleteConfirmation) {
                            Button("Delete Permanently", role: .destructive) {
                                performDelete()
                            }
                        } message: {
                            Text("Are you sure you want to delete this organization?")
                        }
                    }
                }
                .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            } else {
                ProgressView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Settings")
    }

    private func performDelete() {
        isDeleting = true
        withErrorHandling {
            try await organizationStore.delete()
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
