import PDFKit
import SwiftUI

struct ViewerPDFThumbnailListViewContainer: View {
    @ObservedObject var document: ViewerPDFDocument
    var pdfView: PDFView

    var body: some View {
        if document.pdfDocument != nil {
            ViewerPDFThumbnailListView(document: document, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}
