import SwiftUI

struct ViewerPDFBasicContainer: View {
    @EnvironmentObject private var state: ViewerPDFBasicState

    var body: some View {
        VStack {
            if state.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                ViewerPDFBasic(state: state)
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            state.loadPDF()
        }
    }
}
