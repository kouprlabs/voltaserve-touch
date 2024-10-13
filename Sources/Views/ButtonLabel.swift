import SwiftUI

struct VOButtonLabel: View {
    var text: String
    var systemImage: String?
    var isLoading: Bool
    var progressViewTint: Color

    init(_ text: String, systemImage: String? = nil, isLoading: Bool = false, progressViewTint: Color = .primary) {
        self.text = text
        self.systemImage = systemImage
        self.isLoading = isLoading
        self.progressViewTint = progressViewTint
    }

    var body: some View {
        HStack {
            if let systemImage {
                Image(systemName: systemImage)
            }
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
    VOButtonLabel("Lorem Ipsum", isLoading: true)
}
