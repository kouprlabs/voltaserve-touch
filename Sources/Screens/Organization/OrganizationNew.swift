import SwiftUI
import VoltaserveCore

struct OrganizationNew: View {
    @EnvironmentObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .disabled(isProcessing)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("New Organization")
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
        isProcessing = true

        VOErrorResponse.withErrorHandling {
            _ = try await organizationStore.create(name: name)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Creating Organization"
            errorMessage = message
            showError = true
        } anyways: {
            isProcessing = false
        }
    }

    private func isValid() -> Bool {
        !name.isEmpty
    }
}
