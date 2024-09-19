import SwiftUI

struct SheetErrorIcon: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(VOColors.red500)
    }
}

struct SheetWarningIcon: View {
    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(VOColors.yellow300)
    }
}

#Preview {
    VStack {
        SheetErrorIcon()
        SheetWarningIcon()
    }
}
