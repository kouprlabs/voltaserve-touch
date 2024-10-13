import Foundation
import SwiftUI

extension Color {
    static func borderColor(colorScheme: ColorScheme) -> Color {
        if colorScheme == .dark {
            Color(.sRGB, red: 255 / 255, green: 255 / 255, blue: 255 / 255, opacity: 0.16)
        } else {
            Color(red: 226 / 255, green: 232 / 255, blue: 240 / 255)
        }
    }
}
