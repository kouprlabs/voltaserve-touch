import SwiftUI
import Voltaserve

struct AccountEditPassword: View {
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section(header: VOSectionHeader("Password")) {
                SecureField("Current Password", text: $currentPassword)
                    .disabled(isSaving)
                SecureField("New Password", text: $newPassword)
                    .disabled(isSaving)
            }
            Section {
                Button {
                    isSaving = true
                    Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                        presentationMode.wrappedValue.dismiss()
                        isSaving = false
                    }
                } label: {
                    HStack {
                        Text("Save")
                        if isSaving {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isSaving)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Change Password")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountEditPassword()
            .environmentObject(AccountStore(VOAuthUser.Entity.devInstance))
    }
}
