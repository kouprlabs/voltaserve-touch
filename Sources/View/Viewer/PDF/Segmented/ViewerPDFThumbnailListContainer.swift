import PDFKit
import SwiftUI

struct ViewerPDFThumbnailListContainer: View {
    @ObservedObject var state: ViewerPDFState
    var pdfView: PDFView

    var body: some View {
        if state.pdfDocument != nil {
            ViewerPDFThumbnailList(state: state, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}
