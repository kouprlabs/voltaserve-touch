import PDFKit
import SwiftUI

struct VPDFThumbnailView: View {
    let page: PDFPage
    let pdfView: PDFView

    var body: some View {
        let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 150), for: .mediaBox)
        Image(uiImage: thumbnail)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .background(Color.gray.opacity(0.2)) // Optional: background to show when no image
            .frame(width: 100, height: 150, alignment: .center) // Optional: adjust frame as needed
            .onTapGesture {
                pdfView.go(to: page)
            }
    }
}
