import SwiftUI

struct VOSheetErrorIcon: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(Color.red500)
    }
}

struct SheetWarningIcon: View {
    var body: some View {
        Image(systemName: "exclamationmark.triangle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30, height: 30)
            .foregroundStyle(Color.yellow300)
    }
}

#Preview {
    VStack {
        VOSheetErrorIcon()
        SheetWarningIcon()
    }
}
