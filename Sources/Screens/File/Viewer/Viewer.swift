import SwiftUI
import VoltaserveCore

struct Viewer: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            ViewerPDF(file)
            ViewerImage(file)
            ViewerVideo(file)
            ViewerAudio(file)
            Viewer3D(file)
            if UIDevice.current.userInterfaceIdiom == .pad {
                ViewerMosaic(file)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                ViewerMosaic(file)
                    .edgesIgnoringSafeArea(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(file.name)
        .modifierIfPad {
            $0.edgesIgnoringSafeArea(.bottom)
        }
    }
}
