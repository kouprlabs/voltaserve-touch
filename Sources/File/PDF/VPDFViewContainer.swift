import SwiftUI

struct VPDFViewContainer: View {
    @EnvironmentObject private var document: VPDFDocument
    @State private var showThumbnails = true

    var body: some View {
        VStack {
            if document.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                VPDFView(document: document, showThumbnails: $showThumbnails)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showThumbnails.toggle()
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
