import SwiftUI
import VoltaserveCore

struct GroupNew: View {
    @EnvironmentObject private var groupStore: GroupStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    @State private var organization: VOOrganization.Entity?
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .disabled(isProcessing)
                NavigationLink {
                    OrganizationSelector { organization in
                        self.organization = organization
                    }
                    .disabled(isProcessing)
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Group")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performSave()
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
        }
    }

    private func performSave() {
        guard let organization else { return }

        isProcessing = true

        VOErrorResponse.withErrorHandling {
            _ = try await groupStore.create(name: name, organization: organization)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Crearing Group"
            errorMessage = message
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        !name.isEmpty && organization != nil
    }
}
