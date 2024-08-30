import SwiftUI
import Voltaserve

struct ViewerSelector: View {
    private var file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            ViewerPDF(file)
            Viewer3D(file)
            ViewerMosaic(file)
        }
    }
}
