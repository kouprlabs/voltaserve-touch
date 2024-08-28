import SwiftUI

struct VOHeading: View {
    var text: String
    var fontSize: CGFloat

    init(_ text: String, fontSize: CGFloat) {
        self.text = text
        self.fontSize = fontSize
    }

    var body: some View {
        Text(text)
            .font(.custom("Unbounded", size: fontSize))
            .fontWeight(.medium)
    }
}

#Preview {
    VOHeading("Hello, World!", fontSize: VOMetrics.headingFontSize)
}
