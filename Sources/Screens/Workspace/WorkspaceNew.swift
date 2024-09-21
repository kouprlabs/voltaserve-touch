import SwiftUI
import VoltaserveCore

struct WorkspaceNew: View {
    @EnvironmentObject private var workspaceStore: WorkspaceStore
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var organization: VOOrganization.Entity?
    @State private var storageCapacity: Int? = 100_000_000_000
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

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
                            Text("Select Organization")
                            if let organization {
                                Spacer()
                                Text(organization.name)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .disabled(isProcessing)
                }
                Section(header: VOSectionHeader("Storage Capacity")) {
                    StoragePicker(value: $storageCapacity)
                        .disabled(isProcessing)
                }
                Section {
                    Button {
                        performCreate()
                    } label: {
                        HStack {
                            Text("Save")
                            if isProcessing {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isProcessing || !isValid())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Workspace")
        }
    }

    private var normalizedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private func performCreate() {
        guard let organization else { return }

        isProcessing = true

        VOErrorResponse.withErrorHandling {
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
