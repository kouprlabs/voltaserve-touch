import SwiftUI

struct ContentView: View {
    @StateObject var mosaicDocument: MosaicDocument
    @StateObject var v3dDocument: V3DDocument
    @StateObject var vpdfDocument: VPDFDocument

    var body: some View {
        Launcher(
            mosaicDocument: mosaicDocument,
            v3dDocument: v3dDocument,
            vpdfDocument: vpdfDocument
        )
    }
}

#Preview {
    ContentView(
        mosaicDocument: MosaicDocument(),
        v3dDocument: V3DDocument(),
        vpdfDocument: VPDFDocument()
    )
}
