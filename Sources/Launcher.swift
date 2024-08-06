import SwiftUI

struct Launcher: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                mosaicButton
                    .padding()
                    .navigationBarHidden(true)
                v3dButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                vpdfButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                Spacer()
            }
            .navigationTitle("Launcher")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var mosaicButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: MosaicView()
                .navigationBarTitle("Mosaic View")) {
                    Text("Launch Mosaic View")
                }
        })
    }

    var v3dButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: V3DView()
                .navigationBarTitle("3D View")
            ) {
                Text("Launch 3D View")
            }
        })
    }

    var vpdfButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: VPDFViewContainer()
                .navigationBarTitle("PDF View")
            ) {
                Text("Launch PDF View")
            }
        })
    }
}

#Preview {
    Launcher()
}
