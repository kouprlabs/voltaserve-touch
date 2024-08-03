import SwiftUI

@main
struct VoltaserveApp: App {
    @StateObject private var viewModel = MosaicViewModel()
    
    var body: some Scene {
        WindowGroup {
            MosaicView(viewModel: viewModel)
        }
    }
}
