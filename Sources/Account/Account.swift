import SwiftUI
import Voltaserve

struct Account: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var user: VOUser.Entity
    @State private var fullName: String
    @State private var email: String
    @State private var password = "xxxxxx"
    @State private var showDeleteAlert = false
    @State private var isLoading = false

    init() {
        let user = VOUser.Entity(
            id: UUID().uuidString,
            username: "anass@koupr.com",
            email: "anass@koupr.com",
            fullName: "Anass Bouassaba",
            createTime: Date().ISO8601Format()
        )
        self.user = user
        fullName = user.fullName
        email = user.email
    }

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
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
                        presentationMode.wrappedValue.dismiss()
                    }
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
                    }
                    print("Perform account deletion...")
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure want to delete your account?")
            }
        }
    }
}

#Preview {
    Account()
}
