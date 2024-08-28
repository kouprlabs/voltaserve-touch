import SwiftUI

struct ForgotPassword: View {
    @State var isLoading = false
    @State var email: String = ""

    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
            Text("Forgot Password")
                .voHeading(fontSize: VOMetrics.headingFontSize)
            Text("Please provide your account Email where we can send you the password recovery instructions.")
                .voFormHintText()
                .frame(width: VOMetrics.formWidth)
                .multilineTextAlignment(.center)
            TextField("Email", text: $email)
                .voTextField(width: VOMetrics.formWidth)
                .disabled(isLoading)
            Button {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isLoading = false
                }
            } label: {
                VOButtonLabel("Send Recovery Instructions", isLoading: isLoading)
            }
            .voButton(width: VOMetrics.formWidth, isDisabled: isLoading)
            HStack {
                Text("Password recovered?")
                    .voFormHintText()
                Button {} label: {
                    Text("Sign In")
                        .voFormHintLabel()
                }
                .disabled(isLoading)
            }
        }
    }
}

#Preview {
    ForgotPassword()
}
