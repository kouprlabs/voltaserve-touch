import SwiftUI

struct VOButtonLabel: View {
    var text: String
    var isLoading: Bool
    var progressViewTint: Color

    init(_ text: String, isLoading: Bool, progressViewTint: Color = .primary) {
        self.text = text
        self.isLoading = isLoading
        self.progressViewTint = progressViewTint
    }

    var body: some View {
        HStack {
            Text(text)
            if isLoading {
                ProgressView()
                    .tint(progressViewTint)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    VOButtonLabel("Hello, World!", isLoading: true)
}
