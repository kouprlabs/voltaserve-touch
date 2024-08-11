import PDFKit
import SwiftUI

struct ViewerPDFThumbnailListContainer: View {
    @ObservedObject var vm: ViewerPDFViewModel
    var pdfView: PDFView

    var body: some View {
        if vm.pdfDocument != nil {
            ViewerPDFThumbnailList(vm: vm, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}
