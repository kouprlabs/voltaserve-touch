import SwiftUI

enum VOColors {
    static let blue50 = Color(hex: "#E7EDFE")
    static let blue100 = Color(hex: "#BBCDFC")
    static let blue200 = Color(hex: "#8FACF9")
    static let blue300 = Color(hex: "#648CF7")
    static let blue400 = Color(hex: "#386CF5")
    static let blue500 = Color(hex: "#0C4CF3")
    static let blue600 = Color(hex: "#0A3CC2")
    static let blue700 = Color(hex: "#072D92")
    static let blue800 = Color(hex: "#051E61")
    static let blue900 = Color(hex: "#020F31")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = (Double((int >> 16) & 0xFF), Double((int >> 8) & 0xFF), Double(int & 0xFF))
        case 8: // ARGB (32-bit)
            (r, g, b) = (Double((int >> 16) & 0xFF), Double((int >> 8) & 0xFF), Double(int & 0xFF))
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: r / 255.0,
            green: g / 255.0,
            blue: b / 255.0,
            opacity: 1.0
        )
    }
}
