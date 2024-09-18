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
                Section(header: VOSectionHeader("Email")) {
                    TextField("Email", text: $value)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isSaving)
                }
                Section {
                    Button {
                        performSave()
                    } label: {
                        HStack {
                            Text("Save Email")
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
                    Text("Change Email")
                        .font(.headline)
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
