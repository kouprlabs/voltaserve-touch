import SwiftUI

struct Launcher: View {
    @EnvironmentObject private var viewer3DDocument: Viewer3DDocument
    @EnvironmentObject private var viewerMosaicDocument: ViewerMosaicDocument
    @EnvironmentObject private var viewerBasicPDFDocument: ViewerBasicPDFDocument
    @EnvironmentObject private var viewerPDFDocument: ViewerPDFDocument

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                mosaicButton
                    .padding()
                    .navigationBarHidden(true)
                    .onAppear {
                        viewerMosaicDocument.shuffleFileId()
                    }
                viewer3DButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewer3DDocument.shuffleFileId()
                    }
                viewerBasicPDFButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewerBasicPDFDocument.shuffleFileId()
                    }
                viewerPDFButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewerPDFDocument.shuffleFileId()
                    }
                Spacer()
            }
            .navigationTitle("Launcher")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var mosaicButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: ViewerMosaicView()
                .navigationBarTitle("Mosaic Viewer")) {
                    Text("Launch Mosaic Viewer")
                }
        })
    }

    var viewer3DButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: Viewer3DView()
                .navigationBarTitle("3D Viewer")
            ) {
                Text("Launch 3D Viewer")
            }
        })
    }

    var viewerBasicPDFButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: ViewerBasicPDFViewContainer()
                .navigationBarTitle("Basic PDF Viewer")
            ) {
                Text("Launch Basic PDF Viewer")
            }
        })
    }

    var viewerPDFButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: ViewerPDFViewContainer()
                .navigationBarTitle("PDF Viewer")
            ) {
                Text("Launch PDF Viewer")
            }
        })
    }
}

#Preview {
    Launcher()
}
