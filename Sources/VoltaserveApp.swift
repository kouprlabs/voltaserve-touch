import SwiftUI
import VoltaserveCore

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
                .environmentObject(GroupStore())
                .environmentObject(GroupMembersStore())
                .environmentObject(OrganizationStore())
                .environmentObject(OrganizationMembersStore())
                .environmentObject(PDFStore())
                .environmentObject(ImageStore())
                .environmentObject(VideoStore())
                .environmentObject(AudioStore())
                .environmentObject(GLBStore())
                .environmentObject(MosaicStore())
                .environmentObject(BrowserStore())
                .environmentObject(ServerStore())
        }
    }
}
