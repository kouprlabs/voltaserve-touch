import SwiftUI

struct ViewerBasicPDFViewContainer: View {
    @EnvironmentObject private var document: ViewerBasicPDFDocument

    var body: some View {
        VStack {
            if document.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                ViewerBasicPDFView(document: document)
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            document.loadPDF()
        }
    }
}
