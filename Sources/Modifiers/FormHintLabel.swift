import SwiftUI

struct VOFormHintLabel: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .font(.custom(VOMetrics.bodyFontFamily, size: 15))
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            .underline()
    }
}

extension View {
    func voFormHintLabel() -> some View {
        modifier(VOFormHintLabel())
    }
}

#Preview {
    Button {} label: {
        Text("Lorem ipsum")
            .voFormHintLabel()
    }
}
