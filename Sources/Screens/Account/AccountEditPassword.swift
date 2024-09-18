import SwiftUI
import VoltaserveCore

struct AccountEditPassword: View {
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var currentValue = ""
    @State private var newValue = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: VOSectionHeader("Password")) {
                SecureField("Current Password", text: $currentValue)
                    .disabled(isSaving)
                SecureField("New Password", text: $newValue)
                    .disabled(isSaving)
            }
            Section {
                Button {
                    performSave()
                } label: {
                    HStack {
                        Text("Save Password")
                        if isSaving {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isSaving || !isValid())
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Change Password")
                    .font(.headline)
            }
        }
        .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
    }

    private func performSave() {
        isSaving = true
        VOErrorResponse.withErrorHandling {
            try await accountStore.updatePassword(current: currentValue, new: newValue)
        } success: {
            presentationMode.wrappedValue.dismiss()
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
