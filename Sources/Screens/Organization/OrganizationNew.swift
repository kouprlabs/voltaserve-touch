import SwiftUI
import VoltaserveCore

struct OrganizationNew: View {
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    init(organizationStore: OrganizationStore) {
        self.organizationStore = organizationStore
    }

    var body: some View {
        NavigationView {
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
        isProcessing = true
        withErrorHandling {
            _ = try await organizationStore.create(name: normalizedName)
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
        !normalizedName.isEmpty
    }
}
