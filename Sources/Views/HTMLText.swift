import SwiftUI

struct HTMLText: View {
    @Environment(\.colorScheme) private var colorScheme
    private let text: String
    private let color: Color?
    private let fontSize: CGFloat
    private let fontFamily: String

    init(
        _ text: String,
        color: Color? = nil,
        fontSize: CGFloat = VOMetrics.bodyFontSize,
        fontFamily: String = VOMetrics.bodyFontFamily
    ) {
        self.text = text
        self.color = color
        self.fontSize = fontSize
        self.fontFamily = fontFamily
    }

    var body: some View {
        if let attributedString = htmlToAttributedString() {
            Text(attributedString)
        } else {
            Text(text)
        }
    }

    private func htmlToAttributedString() -> AttributedString? {
        let cssFontSize = "font-size: \(fontSize)px"
        let cssFontFamily = "font-family: '\(fontFamily)'"
        let cssDisplay = "display: inline"
        var cssColor = colorScheme == .dark ? "color: white" : "color: black"
        if let color {
            if let hex = color.toHexString() {
                cssColor = "color: \(hex)"
            }
        }

        let style = "\(cssFontSize); \(cssFontFamily); \(cssDisplay); \(cssColor);"
        let html = "<div style=\"\(style)\">\(text)</div>"

        guard let data = html.data(using: .utf8) else { return nil }

        do {
            return try AttributedString(
                NSAttributedString(
                    data: data,
                    options: [.documentType: NSAttributedString.DocumentType.html],
                    documentAttributes: nil
                )
            )
        } catch {
            return nil
        }
    }
}
