import SwiftUI
import VoltaserveCore

struct AccountEditPassword: View {
    @ObservedObject private var accountStore: AccountStore
    @Environment(\.dismiss) private var dismiss
    @State private var currentValue = ""
    @State private var newValue = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    init(accountStore: AccountStore) {
        self.accountStore = accountStore
    }

    var body: some View {
        Form {
            SecureField("Current Password", text: $currentValue)
                .disabled(isSaving)
            SecureField("New Password", text: $newValue)
                .disabled(isSaving)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Change Password")
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
    }

    private func performSave() {
        isSaving = true

        withErrorHandling {
            try await accountStore.updatePassword(current: currentValue, new: newValue)
            return true
        } success: {
            dismiss()
        } failure: { message in
            errorTitle = "Error: Saving Password"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        !currentValue.isEmpty && !newValue.isEmpty
    }
}
