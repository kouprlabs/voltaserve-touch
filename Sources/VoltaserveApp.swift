import SwiftUI

@main
struct VoltaserveApp: App {
    @StateObject private var mosaicDocument = MosaicDocument()
    @StateObject private var v3dDocument = V3DDocument()
    @StateObject private var vpdfViewModel = VPDFDocument()

    var body: some Scene {
        WindowGroup {
            ContentView(
                mosaicDocument: mosaicDocument,
                v3dDocument: v3dDocument,
                vpdfDocument: vpdfViewModel
            )
            .background(Color.green)
        }
    }
}
