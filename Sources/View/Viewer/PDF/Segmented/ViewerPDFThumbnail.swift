import PDFKit
import SwiftUI

struct ViewerPDFThumbnail: View {
    @ObservedObject var state: ViewerPDFState

    let index: Int
    let pdfView: PDFView

    var body: some View {
        if let thumbnail = state.loadedThumbnails[index] {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.gray.opacity(0.2))
                .frame(width: 100, height: 150, alignment: .center)
                .border(Color.black, width: state.currentPage == index ? 2 : 0)
                .onTapGesture {
                    Task {
                        state.currentPage = index
                        await state.loadPage(at: index)
                    }
                }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 100, height: 150, alignment: .center)
        }
    }
}
