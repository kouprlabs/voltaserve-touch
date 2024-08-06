import SwiftUI

@main
struct VoltaserveApp: App {
//    @StateObject private var mosaicDocument = MosaicDocument()
    @StateObject private var v3dDocument = V3DDocument()
//    @StateObject private var vpdfViewModel = VPDFDocument()

    var body: some Scene {
        WindowGroup {
//            MosaicLauncher(document: mosaicDocument)
            V3DLauncher(document: v3dDocument)
//            VPDFLauncher(document: vpdfViewModel)
        }
    }
}
