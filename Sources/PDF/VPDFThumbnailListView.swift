import SwiftUI
import PDFKit

struct VPDFThumbnailListView: View {
    let document: PDFDocument
    let pdfView: PDFView

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<document.pageCount, id: \.self) { index in
                    if let page = document.page(at: index) {
                        VPDFThumbnailView(page: page, pdfView: pdfView)
                    } else {
                        Text("Error loading page")
                    }
                }
            }
            .padding(16)
        }
    }
}