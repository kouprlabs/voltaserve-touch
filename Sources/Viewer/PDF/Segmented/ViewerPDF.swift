import PDFKit
import SwiftUI

struct ViewerPDF: View {
    @ObservedObject private var state = ViewerPDFStore()
    @State private var showThumbnails = true

    var body: some View {
        VStack {
            ViewerPDFPage(state: state)
            if showThumbnails {
                ViewerPDFThumbnailList(state: state, pdfView: PDFView())
            }
        }
        .clipped()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        showThumbnails.toggle()
                    }
                }, label: {
                    Label(
                        "Toggle Thumbnails",
                        systemImage: showThumbnails ? "rectangle.bottomhalf.filled" : "rectangle.split.1x2"
                    )
                })
            }
        }.onAppear {
            Task {
                await state.loadPDF()
            }
        }
    }
}
