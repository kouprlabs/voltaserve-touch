import SwiftUI

struct VOLogo: View {
    @Environment(\.colorScheme) var colorScheme
    var isGlossy = false
    var size: CGSize

    var body: some View {
        if colorScheme == .dark {
            if isGlossy {
                Image("logo-dark-glossy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            } else {
                Image("logo-dark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            }
        } else {
            if isGlossy {
                Image("logo-glossy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            } else {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
            }
        }
    }
}

#Preview {
    VOLogo(size: .init(width: 200, height: 200))
}
