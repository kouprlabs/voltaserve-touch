import PDFKit
import SwiftUI

struct VSegmentedPDFThumbnailListViewContainer: View {
    @ObservedObject var document: VSegmentedPDFDocument
    var pdfView: PDFView

    var body: some View {
        if document.pdfDocument != nil {
            VSegmentedPDFThumbnailListView(document: document, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}
