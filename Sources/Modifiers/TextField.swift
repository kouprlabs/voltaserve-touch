import SwiftUI

struct VOTextField: ViewModifier {
    var width: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: width)
            .padding()
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

extension View {
    func voTextField(width: CGFloat) -> some View {
        modifier(VOTextField(width: width))
    }
}

#Preview {
    TextField("Email", text: .constant(""))
        .voTextField(width: VOMetrics.formWidth)
}
