import SwiftUI

struct VOHeading: ViewModifier {
    var fontSize: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.custom("Unbounded", size: fontSize))
            .fontWeight(.medium)
    }
}

extension View {
    func voHeading(fontSize: CGFloat) -> some View {
        modifier(VOHeading(fontSize: fontSize))
    }
}

#Preview {
    Text("Hello, World!")
        .voHeading(fontSize: VOMetrics.headingFontSize)
}
