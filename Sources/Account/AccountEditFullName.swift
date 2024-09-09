import SwiftUI
import VoltaserveCore

struct AccountEditFullName: View {
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
                        isSaving = true
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                            Task { @MainActor in
                                presentationMode.wrappedValue.dismiss()
                                isSaving = false
                            }
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
                    Text("Change Full Name")
                        .font(.headline)
                }
            }
            .onAppear {
                value = user.fullName
            }
            .onChange(of: accountStore.user) { _, newUser in
                if let newUser {
                    value = newUser.fullName
                }
            }
        } else {
            ProgressView()
        }
    }
}

#Preview {
    NavigationStack {
        AccountEditFullName()
            .environmentObject(AccountStore(VOAuthUser.Entity.devInstance))
    }
}
