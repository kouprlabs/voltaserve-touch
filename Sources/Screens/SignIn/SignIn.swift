import SwiftUI
import VoltaserveCore

struct SignIn: View {
    var onCompleted: (() -> Void)?
    @EnvironmentObject private var authStore: AuthStore
    @State private var isLoading = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var showError = false

    init(_ onCompleted: (() -> Void)? = nil) {
        self.onCompleted = onCompleted
    }

    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
            Text("Sign In to Voltaserve")
                .voHeading(fontSize: VOMetrics.headingFontSize)
            TextField("Email", text: $email)
                .voTextField(width: VOMetrics.formWidth)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .disabled(isLoading)
            SecureField("Password", text: $password)
                .voTextField(width: VOMetrics.formWidth)
                .disabled(isLoading)
            Button {
                signIn()
            } label: {
                VOButtonLabel(
                    "Sign In",
                    isLoading: isLoading,
                    progressViewTint: .white
                )
            }
            .voButton(width: VOMetrics.formWidth, isDisabled: isLoading)
            VStack {
                HStack {
                    Text("Don't have an account yet?")
                        .voFormHintText()
                    Button {
                        showSignUp = true
                    } label: {
                        Text("Sign Up")
                            .voFormHintLabel()
                    }
                    .disabled(isLoading)
                }
                HStack {
                    Text("Cannot sign in?")
                        .voFormHintText()
                    Button {
                        showForgotPassword = true
                    } label: {
                        Text("Reset Password")
                            .voFormHintLabel()
                    }
                    .disabled(isLoading)
                }
            }
        }
        .fullScreenCover(isPresented: $showSignUp) {
            SignUp {
                showSignUp = false
            } onSignIn: {
                showSignUp = false
            }
        }
        .fullScreenCover(isPresented: $showForgotPassword) {
            ForgotPassword {
                showForgotPassword = false
            } onSignIn: {
                showForgotPassword = false
            }
        }
        .alert(VOTextConstants.errorAlertTitle, isPresented: $showError) {
            Button(VOTextConstants.errorAlertButtonLabel) {}
        } message: {
            Text(errorMessage)
        }
        .padding()
    }

    func signIn() {
        Task {
            isLoading = true
            defer {
                isLoading = false
            }
            do {
                let token = try await authStore.signIn(username: email, password: password)
                Task { @MainActor in
                    authStore.token = token
                    KeychainManager.standard.saveToken(token, forKey: KeychainManager.Constants.tokenKey)
                    onCompleted?()
                }
            } catch let error as VOErrorResponse {
                Task { @MainActor in
                    errorMessage = error.userMessage
                    showError = true
                }
            } catch {
                print(error.localizedDescription)
                Task { @MainActor in
                    errorMessage = VOTextConstants.unexpectedErrorOccurred
                    showError = true
                }
            }
        }
    }
}

#Preview {
    SignIn()
}
