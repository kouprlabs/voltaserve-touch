import SwiftUI

struct VOAvatar: View {
    var name: String
    var size: CGFloat

    public init(name: String, size: CGFloat) {
        self.name = name
        self.size = size
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(randomColor(from: name))
                    .frame(width: size, height: size)
                Text(initials(name))
                    .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.3))
                    .foregroundStyle(colorForBackground(randomColor(from: name)))
            }
        }
        .frame(width: size, height: size)
    }

    private func randomColor(from string: String) -> Color {
        var hash = 0
        for char in string.unicodeScalars {
            hash = Int(char.value) &+ ((hash << 5) &- hash)
        }

        var color = ""
        for i in 0 ..< 3 {
            let value = (hash >> (i * 8)) & 0xFF
            color += String(format: "%02x", value)
        }

        return Color(hex: color)
    }

    private func initials(_ name: String) -> String {
        let nameComponents = name.split(separator: " ")
        if let firstName = nameComponents.first, let lastName = nameComponents.dropFirst().first {
            return "\(firstName.first!)\(lastName.first!)".uppercased()
        } else if let firstName = nameComponents.first {
            return "\(firstName.first!)".uppercased()
        }
        return ""
    }

    func colorForBackground(_ color: Color) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        return luminance > 0.5 ? Color.black : Color.white
    }
}

#Preview {
    VStack {
        VOAvatar(name: "Bruce Wayne", size: 100)
        VOAvatar(name: "你好世界!!!", size: 100)
        VOAvatar(name: "مرحبا بالجميع", size: 100)
    }
}
