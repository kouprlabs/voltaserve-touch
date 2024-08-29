import SwiftUI
import Voltaserve

@main
struct VoltaserveApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .font(.custom(VOMetrics.bodyFontFamily, size: VOMetrics.bodyFontSize))
                .environmentObject(AccountStore())
                .environmentObject(SignUpStore())
                .environmentObject(AuthStore())
                .environmentObject(WorkspaceStore())
        }
    }
}
