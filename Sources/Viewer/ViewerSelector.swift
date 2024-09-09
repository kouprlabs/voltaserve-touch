import SwiftUI
import VoltaserveCore

struct ViewerSelector: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            ViewerPDF(file)
            Viewer3D(file)
            if UIDevice.current.userInterfaceIdiom == .pad {
                ViewerMosaic(file)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                ViewerMosaic(file)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(file.name)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}
