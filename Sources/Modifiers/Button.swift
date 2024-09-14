import SwiftUI

struct VOButton: ViewModifier {
    var width: CGFloat
    var isDisabled: Bool

    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(width: width, height: 40)
            .padding(.horizontal)
            .background(VOColors.blue500)
            .cornerRadius(20)
            .opacity(isDisabled ? 0.5 : 1)
            .disabled(isDisabled)
    }
}

extension View {
    func voButton(width: CGFloat, isDisabled: Bool = false) -> some View {
        modifier(VOButton(width: width, isDisabled: isDisabled))
    }
}

#Preview {
    Button("Lorem Ipsum", action: {})
        .voButton(width: VOMetrics.formWidth)
}
