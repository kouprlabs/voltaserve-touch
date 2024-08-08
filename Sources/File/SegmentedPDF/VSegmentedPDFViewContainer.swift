import PDFKit
import SwiftUI

struct VSegmentedPDFViewContainer: View {
    @EnvironmentObject private var document: VSegmentedPDFDocument
    @State private var showThumbnails = true

    var body: some View {
        VStack {
            // Separate top part with loading spinner if needed
            ZStack {
                VSegmentedPDFPageView(document: document)
                    .edgesIgnoringSafeArea(.all)
            }

            // Thumbnails view at bottom, always visible
            if showThumbnails {
                VSegmentedPDFThumbnailListView(document: document, pdfView: PDFView())
                    .frame(height: 150)
                    .background(Color.white)
                    .transition(.slide)
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
