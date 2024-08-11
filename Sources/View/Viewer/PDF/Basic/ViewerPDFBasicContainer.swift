import SwiftUI

struct ViewerPDFBasicContainer: View {
    @EnvironmentObject private var vm: ViewerPDFBasicViewModel

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                ViewerPDFBasic(vm: vm)
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            vm.loadPDF()
        }
    }
}
