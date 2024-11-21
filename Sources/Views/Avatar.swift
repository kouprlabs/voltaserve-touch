// Copyright (c) 2024 Anass Bouassaba.
//
// Use of this software is governed by the Business Source License
// included in the file LICENSE in the root of this repository.
//
// As of the Change Date specified in that file, in accordance with
// the Business Source License, use of this software will be governed
// by the GNU Affero General Public License v3.0 only, included in the file
// AGPL-3.0-only in the root of this repository.

import SwiftUI

struct VOAvatar: View {
    var name: String
    var size: CGFloat
    var url: URL?

    public init(name: String, size: CGFloat, url: URL? = nil) {
        self.name = name
        self.size = size
        self.url = url
    }

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } placeholder: {
                ZStack {
                    Circle()
                        .fill(randomColor(from: name))
                        .frame(width: size, height: size)
                    Text(initials(name))
                        .font(.system(size: min(geometry.size.width, geometry.size.height) * 0.3))
                        .foregroundStyle(randomColor(from: name).textColor())
                }
            }
        }
        .frame(width: size, height: size)
        .overlay(Circle().stroke(Color(.systemGray4), lineWidth: 1))
    }

    private func randomColor(from string: String) -> Color {
        var hash = 0
        for char in string.unicodeScalars {
            hash = Int(char.value) &+ ((hash << 5) &- hash)
        }

        var color = ""
        for index in 0 ..< 3 {
            let value = (hash >> (index * 8)) & 0xFF
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
}

#Preview {
    VStack(spacing: VOMetrics.spacing) {
        VOAvatar(name: "Bruce Wayne", size: 100)
        VOAvatar(name: "你好世界!!!", size: 100)
        VOAvatar(name: "مرحبا بالجميع", size: 100)
    }
}
