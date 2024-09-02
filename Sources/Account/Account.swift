import SwiftUI
import Voltaserve

struct Account: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var accountStore: AccountStore
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDeleteAlert = false
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if accountStore.user == nil ||
                    accountStore.accountStorageUsage == nil {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let user = accountStore.user {
                    VOAvatar(name: user.fullName, size: 100, base64Image: user.picture)
                    Form {
                        Section(header: Text("Storage Usage")) {
                            VStack(alignment: .leading) {
                                if let storageUsage = accountStore.accountStorageUsage {
                                    // swiftlint:disable:next line_length
                                    Text("\(storageUsage.bytes.prettyBytes()) of \(storageUsage.maxBytes.prettyBytes()) used")
                                    ProgressView(value: Double(storageUsage.percentage) / 100.0)
                                } else {
                                    Text("Calculating…")
                                    ProgressView()
                                }
                            }
                        }
                        Section(header: Text("Basics")) {
                            NavigationLink(destination: Text("Change Full Name")) {
                                HStack {
                                    Text("Full name")
                                    Spacer()
                                    Text(user.fullName)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        Section(header: Text("Credentials")) {
                            NavigationLink(destination: Text("Change Email")) {
                                HStack {
                                    Text("Email")
                                    Spacer()
                                    Text(user.email)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            NavigationLink(destination: Text("Change Password")) {
                                HStack {
                                    Text("Password")
                                    Spacer()
                                    Text(String(repeating: "•", count: 10))
                                }
                            }
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
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .alert(VOTextConstants.errorTitle, isPresented: $showError) {
            Button("OK") {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Delete Permanently", role: .destructive) {}
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
                    errorMessage = VOTextConstants.unexpectedError
                }
            }
        }
    }

    func fetchAccountStorageUsage() {
        Task {
            do {
                let usage = try await accountStore.fetchAccountStorageUsage()
                Task { @MainActor in
                    accountStore.accountStorageUsage = usage
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
                    errorMessage = VOTextConstants.unexpectedError
                }
            }
        }
    }
}

#Preview {
    Account()
        .environmentObject(AuthStore(VOToken.Value.devInstance))
        .environmentObject(AccountStore())
}
