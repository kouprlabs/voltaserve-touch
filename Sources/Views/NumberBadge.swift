import SwiftUI

struct VONumberBadge: View {
    @Environment(\.colorScheme) private var colorScheme
    private let value: Int

    init(_ value: Int) {
        self.value = value
    }

    var body: some View {
        Text("\(value)")
            .padding(value > 9 ? VOMetrics.spacingSm : 0)
            .font(.footnote)
            .frame(height: 24)
            .frame(minWidth: 24)
            .foregroundStyle(colorScheme == .dark ? .black : .white)
            .background(colorScheme == .dark ? .white : .black)
            .cornerRadius(12)
    }
}

#Preview {
    VStack {
        VONumberBadge(1)
        VONumberBadge(10)
        VONumberBadge(100)
        VONumberBadge(1000)
    }
}
