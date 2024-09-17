import SwiftUI
import VoltaserveCore

struct FileViewer: View {
    private let file: VOFile.Entity

    init(_ file: VOFile.Entity) {
        self.file = file
    }

    var body: some View {
        VStack {
            PDFViewer(file)
            ImageViewer(file)
            VideoPlayer(file)
            AudioPlayer(file)
            GLBViewer(file)
            if UIDevice.current.userInterfaceIdiom == .pad {
                MosaicViewer(file)
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                MosaicViewer(file)
                    .edgesIgnoringSafeArea(.horizontal)
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
