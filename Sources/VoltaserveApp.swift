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
                .environmentObject(FileStore())
                .environmentObject(GroupStore())
                .environmentObject(GroupMembersStore())
                .environmentObject(OrganizationStore())
                .environmentObject(OrganizationMembersStore())
                .environmentObject(Viewer3DStore())
                .environmentObject(ViewerPDFStore())
                .environmentObject(ViewerImageStore())
                .environmentObject(ViewerMosaicStore())
        }
    }
}
