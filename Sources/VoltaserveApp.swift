import SwiftUI

@main
struct VoltaserveApp: App {
    @StateObject private var viewModel = MosaicDocument()

    var body: some Scene {
        WindowGroup {
            MosaicView(document: viewModel)
        }
    }
}
