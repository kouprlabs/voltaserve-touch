import SwiftUI

struct VOButton: ViewModifier {
    var width: CGFloat?
    var isDisabled: Bool
    var color: Color

    init(
        color: Color = VOColors.blue500,
        width: CGFloat? = nil,
        isDisabled: Bool = false
    ) {
        self.color = color
        self.width = width
        self.isDisabled = isDisabled
    }

    func body(content: Content) -> some View {
        if let width {
            content
                .frame(width: width, height: VOButtonMetrics.height)
                .modifier(VOButtonCommons(self))
        } else {
            content
                .frame(height: VOButtonMetrics.height)
                .frame(maxWidth: .infinity)
                .modifier(VOButtonCommons(self))
        }
    }
}

struct VOButtonCommons: ViewModifier {
    var button: VOButton

    init(_ button: VOButton) {
        self.button = button
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .foregroundColor(button.color.colorForBackground())
            .background(button.color)
            .cornerRadius(VOButtonMetrics.height / 2)
            .opacity(button.isDisabled ? 0.5 : 1)
            .disabled(button.isDisabled)
    }
}

enum VOButtonMetrics {
    static let height: CGFloat = 40
}

extension View {
    func voButton(
        color: Color = VOColors.blue500,
        width: CGFloat? = nil,
        isDisabled: Bool = false
    ) -> some View {
        modifier(VOButton(color: color, width: width, isDisabled: isDisabled))
    }
}

#Preview {
    VStack {
        Button("Lorem Ipsum", action: {})
            .voButton(width: 60)
        Button("Lorem Ipsum", action: {})
            .voButton(width: 200)
        Button("Dolor Sit Amet", action: {})
            .voButton(color: VOColors.gray200)
            .padding(.horizontal)
    }
}
