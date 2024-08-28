import SwiftUI

struct VOButton: View {
    var label: String
    var width: CGFloat
    var action: () -> Void

    init(_ label: String, width: CGFloat, action: @escaping () -> Void) {
        self.label = label
        self.width = width
        self.action = action
    }

    var body: some View {
        Button(label, action: action)
            .foregroundColor(.white)
            .frame(width: width, height: 40)
            .padding(.horizontal)
            .background(VOColors.blue500)
            .cornerRadius(20)
    }
}

#Preview {
    VOButton(
        "Sign In",
        width: VOMetrics.formWidth,
        action: {}
    )
}
