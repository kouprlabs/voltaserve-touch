import SwiftUI

struct MosaicLauncher: View {
    @StateObject var document: MosaicDocument

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {}) {
                    NavigationLink(destination: MosaicView(document: document)) {
                        Text("Launch Mosaic View")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .navigationTitle("Mosaic Launcher")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures it behaves like a single view, not split view
    }
}
