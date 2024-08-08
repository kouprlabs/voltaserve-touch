import PDFKit
import SwiftUI

struct VPDFThumbnailView: View {
    let index: Int
    @ObservedObject var document: VPDFDocument
    let pdfView: PDFView

    var body: some View {
        if let thumbnail = document.loadedThumbnails[index] {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                // Background to show when no image
                .background(Color.gray.opacity(0.2))
                .frame(width: 100, height: 150, alignment: .center)
                .onTapGesture {
                    if let page = document.pdfDocument?.page(at: index) {
                        pdfView.go(to: page)
                    }
                }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 100, height: 150, alignment: .center)
        }
    }
}
