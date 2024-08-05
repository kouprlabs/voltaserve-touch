import SwiftUI

struct V3DLauncher: View {
    @StateObject var document: V3DDocument

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {}, label: {
                    NavigationLink(destination: V3DView(document: document)) {
                        Text("Launch 3D View")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                })
                Spacer()
            }
            .navigationTitle("3D Launcher")
            .navigationBarHidden(true)
        }
        // Ensures it behaves like a single view, not split view
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
