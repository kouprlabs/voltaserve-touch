import SwiftUI

struct VOButtonLabel: View {
    var text: String
    var isLoading: Bool

    init(_ text: String, isLoading: Bool) {
        self.text = text
        self.isLoading = isLoading
    }

    var body: some View {
        HStack {
            Text(text)
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
    }
}

#Preview {
    VOButtonLabel("Hello, World!", isLoading: true)
}
