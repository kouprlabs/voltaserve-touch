import SwiftUI

struct ColorBadge: View {
    var text: String
    var color: Color
    var style: Style

    init(_ text: String, color: Color, style: Style) {
        self.text = text
        self.color = color
        self.style = style
    }

    var body: some View {
        if style == .fill {
        } else if style == .outline {}
        Text(text)
            .font(.footnote)
            .padding(.horizontal)
            .frame(height: 20)
            .modifierIf(style == .fill) {
                $0
                    .foregroundStyle(color.textColor())
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .modifierIf(style == .outline) {
                $0
                    .foregroundStyle(color)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color, lineWidth: 1)
                    }
            }
    }

    enum Style {
        case fill
        case outline
    }
}

#Preview {
    VStack {
        ColorBadge("Red", color: .red400, style: .fill)
        ColorBadge("Purple", color: .purple400, style: .fill)
        ColorBadge("Green", color: .green400, style: .fill)
        ColorBadge("Red", color: .red400, style: .outline)
        ColorBadge("Purple", color: .purple400, style: .outline)
        ColorBadge("Green", color: .green400, style: .outline)
    }
}
