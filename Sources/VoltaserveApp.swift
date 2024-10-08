import SwiftData
import SwiftUI
import VoltaserveCore

@main
struct VoltaserveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(.custom(VOMetrics.bodyFontFamily, size: VOMetrics.bodyFontSize))
                .environmentObject(TokenStore())
                .modelContainer(for: Server.self)
        }
    }
}
