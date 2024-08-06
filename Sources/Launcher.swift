import SwiftUI

struct Launcher: View {
    @StateObject var mosaicDocument: MosaicDocument
    @StateObject var v3dDocument: V3DDocument
    @StateObject var vpdfDocument: VPDFDocument

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                mosaicButton
                    .padding()
                v3dButton
                    .padding()
                vpdfButton
                    .padding()
                Spacer()
            }
            .navigationTitle("Launcher")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            vpdfDocument.loadPDF()
        }
    }

    var mosaicButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: MosaicView(document: mosaicDocument)
                .navigationBarTitle("Mosaic View")) {
                    Text("Launch Mosaic View")
                }
        })
    }

    var v3dButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: V3DView(document: v3dDocument)
                .navigationBarTitle("3D View")
            ) {
                Text("Launch 3D View")
            }
        })
    }

    var vpdfButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: VPDFViewContainer(document: vpdfDocument)
                .navigationBarTitle("PDF View")
            ) {
                Text("Launch PDF View")
            }
        })
    }
}

#Preview {
    Launcher(
        mosaicDocument: MosaicDocument(),
        v3dDocument: V3DDocument(),
        vpdfDocument: VPDFDocument()
    )
}
