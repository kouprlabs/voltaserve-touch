import SwiftUI

struct SignIn: View {
    @State var isLoading = false
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
            Text("Sign In to Voltaserve")
                .voHeading(fontSize: VOMetrics.headingFontSize)
            TextField("Email", text: $email)
                .voTextField(width: VOMetrics.formWidth)
                .disabled(isLoading)
            SecureField("Password", text: $password)
                .voTextField(width: VOMetrics.formWidth)
                .disabled(isLoading)
            Button {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isLoading = false
                }
            } label: {
                VOButtonLabel("Sign In", isLoading: isLoading)
            }
            .voButton(width: VOMetrics.formWidth, isDisabled: isLoading)
            VStack {
                HStack {
                    Text("Don't have an account yet?")
                        .voFormHintText()
                    Button {} label: {
                        Text("Sign Up")
                            .voFormHintLabel()
                    }
                    .disabled(isLoading)
                }
                HStack {
                    Text("Cannot sign in?")
                        .voFormHintText()
                    Button {} label: {
                        Text("Reset Password")
                            .voFormHintLabel()
                    }
                    .disabled(isLoading)
                }
            }
        }
        .padding()
    }
}

#Preview {
    SignIn()
}
