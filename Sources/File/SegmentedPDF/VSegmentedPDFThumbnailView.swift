import PDFKit
import SwiftUI

struct VSegmentedPDFThumbnailView: View {
    let index: Int
    @ObservedObject var document: VSegmentedPDFDocument
    let pdfView: PDFView

    var body: some View {
        if let thumbnail = document.loadedThumbnails[index] {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.gray.opacity(0.2))
                .frame(width: 100, height: 150, alignment: .center)
                .onTapGesture {
                    document.currentPage = index
                    document.loadPage(at: index)
                    print("Thumbnail \(index) tapped, navigating to page \(index)")
                }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 100, height: 150, alignment: .center)
                .onAppear {
                    print("Placeholder for thumbnail \(index)")
                }
        }
    }
}
