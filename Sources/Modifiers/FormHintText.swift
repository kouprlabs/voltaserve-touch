import SwiftUI

struct VOFormHintText: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.custom(VOMetrics.bodyFontFamily, size: 15))
    }
}

extension View {
    func voFormHintText() -> some View {
        modifier(VOFormHintText())
    }
}

#Preview {
    Text("Lorem ipsum dolor imet?")
        .voFormHintText()
}
