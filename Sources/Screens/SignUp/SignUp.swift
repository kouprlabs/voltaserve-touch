import SwiftUI

struct SignUp: View {
    @EnvironmentObject private var store: SignUpStore
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading = false
    private let onCompletion: (() -> Void)?
    private let onSignIn: (() -> Void)?

    init(_ onCompletion: (() -> Void)? = nil, onSignIn: (() -> Void)? = nil) {
        self.onCompletion = onCompletion
        self.onSignIn = onSignIn
    }

    var body: some View {
        NavigationView {
            if let passwordRequirements = store.passwordRequirements {
                VStack(spacing: VOMetrics.spacing) {
                    VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
                    Text("Sign Up to Voltaserve")
                        .voHeading(fontSize: VOMetrics.headingFontSize)
                    TextField("Full name", text: $fullName)
                        .voTextField(width: VOMetrics.formWidth)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isLoading)
                    TextField("Email", text: $email)
                        .voTextField(width: VOMetrics.formWidth)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(isLoading)
                    SecureField("Password", text: $password)
                        .voTextField(width: VOMetrics.formWidth)
                        .disabled(isLoading)
                    VStack(alignment: .listRowSeparatorLeading) {
                        PasswordHint("\(passwordRequirements.minLength) characters.")
                        PasswordHint("\(passwordRequirements.minLowercase) lowercase character.")
                        PasswordHint("\(passwordRequirements.minUppercase) uppercase character.")
                        PasswordHint("\(passwordRequirements.minNumbers) number.")
                        PasswordHint("\(passwordRequirements.minSymbols) special character(s) (!#$%).")
                    }
                    .frame(width: VOMetrics.formWidth)
                    SecureField("Confirm password", text: $confirmPassword)
                        .voTextField(width: VOMetrics.formWidth)
                        .disabled(isLoading)
                    Button {
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            isLoading = false
                            onCompletion?()
                        }
                    } label: {
                        VOButtonLabel(
                            "Sign Up",
                            isLoading: isLoading,
                            progressViewTint: .white
                        )
                    }
                    .voButton(width: VOMetrics.formWidth, isDisabled: isLoading)
                    HStack {
                        Text("Already a member?")
                            .voFormHintText()
                        Button {
                            onSignIn?()
                        } label: {
                            Text("Sign In")
                                .voFormHintLabel()
                        }
                        .disabled(isLoading)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            onSignIn?()
                        } label: {
                            Text("Back to Sign In")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct PasswordHint: View {
    var text: String
    var isFulfilled: Bool

    init(_ text: String, isFulfilled: Bool = false) {
        self.text = text
        self.isFulfilled = isFulfilled
    }

    var body: some View {
        HStack {
            Image(systemName: "checkmark")
                .imageScale(.small)
            Text(text)
                .voFormHintText()
            Spacer()
        }
        .foregroundStyle(isFulfilled ? .green : .secondary)
    }
}

#Preview {
    SignUp()
        .environmentObject(SignUpStore())
}
