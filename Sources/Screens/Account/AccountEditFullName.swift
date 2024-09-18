import SwiftUI
import VoltaserveCore

struct AccountEditFullName: View {
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorTitle: String?
    @State private var errorMessage: String?

    var body: some View {
        if let user = accountStore.identityUser {
            Form {
                Section(header: VOSectionHeader("Full Name")) {
                    TextField("Full Name", text: $value)
                        .disabled(isSaving)
                }
                Section {
                    Button {
                        performSave()
                    } label: {
                        HStack {
                            Text("Save Full Name")
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
                    Text("Change Full Name")
                        .font(.headline)
                }
            }
            .voErrorAlert(isPresented: $showError, title: errorTitle, message: errorMessage)
            .onAppear {
                value = user.fullName
            }
            .onChange(of: accountStore.identityUser) { _, newUser in
                if let newUser {
                    value = newUser.fullName
                }
            }
        } else {
            ProgressView()
        }
    }

    var normalizedValue: String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func performSave() {
        isSaving = true
        VOErrorResponse.withErrorHandling {
            try await accountStore.updateFullName(normalizedValue)
        } success: {
            presentationMode.wrappedValue.dismiss()
        } failure: { message in
            errorTitle = "Error: Saving Full Name"
            errorMessage = message
            showError = true
        } anyways: {
            isSaving = false
        }
    }

    private func isValid() -> Bool {
        if let identityUser = accountStore.identityUser {
            return !normalizedValue.isEmpty && normalizedValue != identityUser.fullName
        }
        return false
    }
}
