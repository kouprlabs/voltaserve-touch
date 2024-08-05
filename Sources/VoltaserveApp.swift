import SwiftUI

@main
struct VoltaserveApp: App {
    @StateObject private var document = MosaicDocument()

    var body: some Scene {
        WindowGroup {
            MosaicLauncher(document: document)
        }
    }
}
