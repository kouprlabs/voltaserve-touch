import SwiftUI
import Voltaserve

struct Account: View {
    @EnvironmentObject private var store: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = "xxxxxx"
    @State private var showDeleteAlert = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading || store.user == nil {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let user = store.user {
                    Avatar(name: user.fullName, size: 100)
                    Form {
                        Section(header: Text("Basics")) {
                            TextField("Full name", text: $fullName)
                        }
                        Section(header: Text("Credentials")) {
                            TextField("Email", text: $email)
                            SecureField("Password", text: $password)
                        }
                        Section(header: Text("Advanced")) {
                            Button("Delete Account", role: .destructive) {
                                showDeleteAlert = true
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Account")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Task { @MainActor in
                            isLoading = true
                            try await store.update(email: email, fullName: fullName)
                            isLoading = false
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert("Delete Account", isPresented: $showDeleteAlert) {
                Button("OK", role: .destructive) {
                    isLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isLoading = false
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure want to delete your account?")
            }
        }
        .onAppear {
            if let user = store.user {
                fullName = user.fullName
                email = user.email
            }
        }
        .onChange(of: store.user) { _, newUser in
            if let user = newUser {
                fullName = user.fullName
                email = user.email
            }
        }
    }
}

#Preview {
    Account()
        .environmentObject(AccountStore())
}
