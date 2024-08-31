import SwiftUI
import Voltaserve

struct Account: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = "xxxxxx"
    @State private var showDeleteAlert = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading || accountStore.user == nil {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let user = accountStore.user {
                    VOAvatar(name: user.fullName, size: 100, base64Image: user.picture)
                        .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
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
                            if let user = accountStore.user,
                               fullName != user.fullName || email != user.email {
                                isLoading = true
                                try await accountStore.update(email: email, fullName: fullName)
                                isLoading = false
                            }
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
            if let token = authStore.token {
                accountStore.token = token
                fetchUser()
            }
        }
        .onAppear {
            if let user = accountStore.user {
                fullName = user.fullName
                email = user.email
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                accountStore.token = newToken
            }
        }
        .onChange(of: accountStore.user) { _, newUser in
            if let newUser {
                fullName = newUser.fullName
                email = newUser.email
            }
        }
    }

    func fetchUser() {
        Task {
            do {
                let user = try await accountStore.fetchUser()
                Task { @MainActor in
                    accountStore.user = user
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    showError = true
                    errorMessage = error.userMessage
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    showError = true
                    errorMessage = VOMessages.unexpectedError
                }
            }
        }
    }
}

#Preview {
    Account()
        .environmentObject(AuthStore())
        .environmentObject(AccountStore())
}
