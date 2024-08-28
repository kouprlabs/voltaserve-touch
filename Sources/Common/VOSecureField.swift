import SwiftUI

struct VOSecureField: View {
    var label: String
    var text: Binding<String>
    var width: CGFloat

    init(_ label: String, text: Binding<String>, width: CGFloat) {
        self.label = label
        self.text = text
        self.width = width
    }

    var body: some View {
        SecureField(label, text: text)
            .frame(width: width)
            .padding()
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    VOSecureField(
        "Password",
        text: .constant("xxxxxx"),
        width: VOMetrics.formWidth
    )
}
