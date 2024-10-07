import SwiftData
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
                .environmentObject(TokenStore())
                .environmentObject(WorkspaceStore())
                .environmentObject(GroupStore())
                .environmentObject(OrganizationStore())
                .environmentObject(InvitationStore())
                .environmentObject(TaskStore())
                .environmentObject(PDFStore())
                .environmentObject(ImageStore())
                .environmentObject(VideoStore())
                .environmentObject(AudioStore())
                .environmentObject(GLBStore())
                .environmentObject(MosaicStore())
                .modelContainer(for: Server.self)
        }
    }
}
