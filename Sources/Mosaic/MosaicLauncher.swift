import SwiftUI

struct MosaicLauncher: View {
    @StateObject var document: MosaicDocument

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {}, label: {
                    NavigationLink(destination: MosaicView(document: document)) {
                        Text("Launch Mosaic View")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                })
                Spacer()
            }
            .navigationTitle("Mosaic Launcher")
            .navigationBarHidden(true)
        }
        // Ensures it behaves like a single view, not split view
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
