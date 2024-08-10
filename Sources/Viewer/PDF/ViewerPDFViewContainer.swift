import PDFKit
import SwiftUI

struct ViewerPDFViewContainer: View {
    @EnvironmentObject private var document: ViewerPDFDocument
    @State private var showThumbnails = true

    var body: some View {
        VStack {
            // Separate top part with loading spinner if needed
            ZStack {
                ViewerPDFPageView(document: document)
                    .edgesIgnoringSafeArea(.all)
            }

            // Thumbnails view at bottom, always visible
            if showThumbnails {
                ViewerPDFThumbnailListView(document: document, pdfView: PDFView())
                    .frame(height: 150)
                    .background(Color.white)
                    .transition(.move(edge: .bottom))
            }
        }
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
            document.loadPDF()
        }
    }
}
