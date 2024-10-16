import SwiftUI
import VoltaserveCore

struct OrganizationEditName: View {
    @ObservedObject private var organizationStore: OrganizationStore
    @Environment(\.dismiss) private var dismiss
    @State private var value = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    init(organizationStore: OrganizationStore) {
        self.organizationStore = organizationStore
    }

    var body: some View {
        if let current = organizationStore.current {
            Form {
                TextField("Name", text: $value)
                    .disabled(isSaving)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Change Name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            performSave()
                        }
                        .disabled(!isValid())
                    }
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                value = current.name
            }
            .onChange(of: organizationStore.current) { _, newCurrent in
                if let newCurrent {
                    value = newCurrent.name
                }
            }
        } else {
            ProgressView()
        }
    }

    private var nornalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        isSaving = true
        withErrorHandling {
            _ = try await organizationStore.patchName(name: nornalizedValue)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Saving Name"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let current = organizationStore.current {
            return !nornalizedValue.isEmpty && nornalizedValue != current.name
        }
        return false
    }
}
