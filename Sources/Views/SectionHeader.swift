import SwiftUI

struct VOSectionHeader: View {
    var text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text).font(.custom(VOMetrics.bodyFontFamily, size: 13))
    }
}

#Preview {
    VOSectionHeader("Lorem ipsum")
}
