import SwiftUI
import VoltaserveCore

struct AccountEditEmail: View {
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var value = ""
    @State private var isSaving = false

    var body: some View {
        if let user = accountStore.user {
            Form {
                Section(header: VOSectionHeader("Name")) {
                    TextField("Name", text: $value)
                        .disabled(isSaving)
                }
                Section {
                    Button {
                        performSave()
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
                    Text("Change Email")
                        .font(.headline)
                }
            }
            .onAppear {
                value = user.email
            }
            .onChange(of: accountStore.user) { _, newUser in
                if let newUser {
                    value = newUser.email
                }
            }
        } else {
            ProgressView()
        }
    }

    private func performSave() {
        isSaving = true
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            Task { @MainActor in
                isSaving = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

#Preview {
    AccountEditEmail()
        .environmentObject(AccountStore(VOAuthUser.Entity.devInstance))
}
