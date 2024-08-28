import SwiftUI

struct SignIn: View {
    var body: some View {
        VStack(spacing: VOMetrics.spacing) {
            VOLogo(isGlossy: true, size: .init(width: 100, height: 100))
            VOHeading("Sign In to Voltaserve", fontSize: VOMetrics.headingFontSize)
            VOTextField("Email", text: .constant(""), width: VOMetrics.formWidth)
            VOSecureField("Password", text: .constant(""), width: VOMetrics.formWidth)
            VOButton("Sign In", width: VOMetrics.formWidth, action: {})
        }
        .padding(VOMetrics.spacing)
    }
}

#Preview {
    SignIn()
}
