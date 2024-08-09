import SwiftUI

struct VPDFViewContainer: View {
    @EnvironmentObject private var document: VPDFDocument

    var body: some View {
        VStack {
            if document.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                VPDFView(document: document)
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            document.loadPDF()
        }
    }
}
