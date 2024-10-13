import SwiftUI
import VoltaserveCore

struct WorkspaceCreate: View {
    @ObservedObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var organization: VOOrganization.Entity?
    @State private var storageCapacity: Int? = 100_000_000_000
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    init(workspaceStore: WorkspaceStore) {
        self.workspaceStore = workspaceStore
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: VOSectionHeader("Basics")) {
                    TextField("Name", text: $name)
                        .disabled(isProcessing)
                    NavigationLink {
                        OrganizationSelector { organization in
                            self.organization = organization
                        }
                    } label: {
                        HStack {
                            Text("Organization")
                            if let organization {
                                Spacer()
                                Text(organization.name)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(isProcessing)
                }
                Section(header: VOSectionHeader("Storage Capacity")) {
                    VOStoragePicker(value: $storageCapacity)
                        .disabled(isProcessing)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Workspace")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Create") {
                            performCreate()
                        }
                        .disabled(!isValid())
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
        }
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func performCreate() {
        guard let organization else { return }
        isProcessing = true

        withErrorHandling {
            _ = try await workspaceStore.create(name: normalizedName, organization: organization)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Creating Workspace"
            errorMessage = message
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        !normalizedName.isEmpty &&
            organization != nil &&
            storageCapacity != nil &&
            storageCapacity! > 0
    }
}
