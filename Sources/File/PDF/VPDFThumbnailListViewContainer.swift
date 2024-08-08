import PDFKit
import SwiftUI

struct VPDFThumbnailListViewContainer: View {
    @ObservedObject var document: VPDFDocument
    var pdfView: PDFView

    var body: some View {
        if document.pdfDocument != nil {
            VPDFThumbnailListView(document: document, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}
