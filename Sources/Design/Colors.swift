import SwiftUI

enum VOColors {
    /* Blue */
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

    /* Gray */
    static let gray50 = Color(hex: "#F7FAFC")
    static let gray100 = Color(hex: "#EDF2F7")
    static let gray200 = Color(hex: "#E2E8F0")
    static let gray300 = Color(hex: "#CBD5E0")
    static let gray400 = Color(hex: "#A0AEC0")
    static let gray500 = Color(hex: "#718096")
    static let gray600 = Color(hex: "#4A5568")
    static let gray700 = Color(hex: "#2D3748")
    static let gray800 = Color(hex: "#1A202C")
    static let gray900 = Color(hex: "#171923")

    /* Red */
    static let red50 = Color(hex: "#FFF5F5")
    static let red100 = Color(hex: "#FED7D7")
    static let red200 = Color(hex: "#FEB2B2")
    static let red300 = Color(hex: "#FC8181")
    static let red400 = Color(hex: "#F56565")
    static let red500 = Color(hex: "#E53E3E")
    static let red600 = Color(hex: "#C53030")
    static let red700 = Color(hex: "#9B2C2C")
    static let red800 = Color(hex: "#822727")
    static let red900 = Color(hex: "#63171B")

    /* Green */
    static let green50 = Color(hex: "#F0FFF4")
    static let green100 = Color(hex: "#C6F6D5")
    static let green200 = Color(hex: "#9AE6B4")
    static let green300 = Color(hex: "#68D391")
    static let green400 = Color(hex: "#48BB78")
    static let green500 = Color(hex: "#38A169")
    static let green600 = Color(hex: "#2F855A")
    static let green700 = Color(hex: "#276749")
    static let green800 = Color(hex: "#22543D")
    static let green900 = Color(hex: "#1C4532")

    /* Yellow */
    static let yellow50 = Color(hex: "#FFFFF0")
    static let yellow100 = Color(hex: "#FEFCBF")
    static let yellow200 = Color(hex: "#FAF089")
    static let yellow300 = Color(hex: "#F6E05E")
    static let yellow400 = Color(hex: "#ECC94B")
    static let yellow500 = Color(hex: "#D69E2E")
    static let yellow600 = Color(hex: "#B7791F")
    static let yellow700 = Color(hex: "#975A16")
    static let yellow800 = Color(hex: "#744210")
    static let yellow900 = Color(hex: "#5F370E")
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

    func colorForBackground() -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5 ? Color.black : Color.white
    }
}
