import SwiftUI
import VoltaserveCore

struct AccountEditEmail: View {
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        if let identityUser = accountStore.identityUser {
            Form {
                TextField("Email", text: $value)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .disabled(isSaving)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Change Email")
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
                value = identityUser.email
            }
            .onChange(of: accountStore.identityUser) { _, newUser in
                if let newUser {
                    value = newUser.email
                }
            }
        } else {
            ProgressView()
        }
    }

    private var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func isValid() -> Bool {
        if let identityUser = accountStore.identityUser {
            return !normalizedValue.isEmpty && normalizedValue != identityUser.email
        }
        return false
    }

    private func performSave() {
        isSaving = true
        VOErrorResponse.withErrorHandling {
            try await accountStore.updateEmail(normalizedValue)
            return true
        } success: {
            presentationMode.wrappedValue.dismiss()
        } failure: { message in
            errorTitle = "Error: Saving Email"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }
}
