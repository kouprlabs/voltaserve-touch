import SwiftUI
import VoltaserveCore

struct AccountSettings: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDelete = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var isDeleting = false

    var body: some View {
        NavigationView {
            VStack {
                if accountStore.user == nil ||
                    accountStore.storageUsage == nil {
                    ProgressView()
                } else if let user = accountStore.user {
                    VOAvatar(name: user.fullName, size: 100, base64Image: user.picture)
                        .padding()
                    Form {
                        Section(header: VOSectionHeader("Storage Usage")) {
                            VStack(alignment: .leading) {
                                if let storageUsage = accountStore.storageUsage {
                                    // swiftlint:disable:next line_length
                                    Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                                    ProgressView(value: Double(storageUsage.percentage) / 100.0)
                                } else {
                                    Text("Calculating…")
                                    ProgressView()
                                }
                            }
                        }
                        Section(header: VOSectionHeader("Basics")) {
                            NavigationLink(destination: AccountEditFullName()) {
                                HStack {
                                    Text("Full name")
                                    Spacer()
                                    Text(user.fullName)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(isDeleting)
                        }
                        Section(header: VOSectionHeader("Credentials")) {
                            NavigationLink(destination: AccountEditEmail()) {
                                HStack {
                                    Text("Email")
                                    Spacer()
                                    Text(user.email)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .disabled(isDeleting)
                            NavigationLink(destination: AccountEditPassword()) {
                                HStack {
                                    Text("Password")
                                    Spacer()
                                    Text(String(repeating: "•", count: 10))
                                }
                            }
                            .disabled(isDeleting)
                            Button("Sign Out", role: .destructive) {
                                authStore.token = nil
                                KeychainManager.standard.delete(KeychainManager.Constants.tokenKey)
                            }
                            .disabled(isDeleting)
                        }
                        Section(header: VOSectionHeader("Advanced")) {
                            Button(role: .destructive) {
                                showDelete = true
                            } label: {
                                HStack {
                                    Text("Delete Account")
                                    if isDeleting {
                                        Spacer()
                                        ProgressView()
                                    }
                                }
                            }
                            .disabled(isDeleting)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Account")
                        .font(.headline)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(isDeleting)
                }
            }
        }
        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .alert("Delete Account", isPresented: $showDelete) {
            Button("Delete Permanently", role: .destructive) {
                isDeleting = true
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                    Task { @MainActor in
                        presentationMode.wrappedValue.dismiss()
                        authStore.token = nil
                        KeychainManager.standard.delete(KeychainManager.Constants.tokenKey)
                        isDeleting = false
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure want to delete your account?")
        }
        .onAppear {
            if let token = authStore.token {
                assignTokenToStores(token)
                fetchData()
            }
        }
        .onChange(of: authStore.token) { _, newToken in
            if let newToken {
                assignTokenToStores(newToken)
                fetchData()
            }
        }
    }

    func assignTokenToStores(_ token: VOToken.Value) {
        accountStore.token = token
    }

    func fetchData() {
        fetchUser()
        fetchAccountStorageUsage()
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
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }

    func fetchAccountStorageUsage() {
        Task {
            do {
                let usage = try await accountStore.fetchAccountStorageUsage()
                Task { @MainActor in
                    accountStore.storageUsage = usage
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
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                }
            }
        }
    }
}

#Preview {
    AccountSettings()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(AccountStore())
}
