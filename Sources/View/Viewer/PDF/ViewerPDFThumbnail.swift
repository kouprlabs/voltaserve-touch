import PDFKit
import SwiftUI

struct ViewerPDFThumbnail: View {
    let index: Int
    @ObservedObject var vm: ViewerPDFViewModel
    let pdfView: PDFView

    var body: some View {
        if let thumbnail = vm.loadedThumbnails[index] {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.gray.opacity(0.2))
                .frame(width: 100, height: 150, alignment: .center)
                .border(Color.black, width: vm.currentPage == index ? 2 : 0)
                .onTapGesture {
                    vm.currentPage = index
                    vm.loadPage(at: index)
                }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 100, height: 150, alignment: .center)
        }
    }
}
