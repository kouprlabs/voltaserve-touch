import SwiftUI

struct Launcher: View {
    @EnvironmentObject private var viewer3DVM: Viewer3DState
    @EnvironmentObject private var viewerMosaicVM: ViewerMosaicViewModel
    @EnvironmentObject private var viewerBasicPDFVM: ViewerPDFBasicViewModel
    @EnvironmentObject private var viewerPDFVM: ViewerPDFViewModel

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                mosaicButton
                    .padding()
                    .navigationBarHidden(true)
                    .onAppear {
                        viewerMosaicVM.shuffleFileId()
                    }
                viewer3DButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewer3DVM.shuffleFileId()
                    }
                viewerBasicPDFButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewerBasicPDFVM.shuffleFileId()
                    }
                viewerPDFButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        viewerPDFVM.shuffleFileId()
                    }
                Spacer()
            }
            .navigationTitle("Launcher")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    var mosaicButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: ViewerMosaic()
                .navigationBarTitle("Mosaic Viewer")) {
                    Text("Launch Mosaic Viewer")
                }
        })
    }

    var viewer3DButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: Viewer3D()
                .navigationBarTitle("3D Viewer")
            ) {
                Text("Launch 3D Viewer")
            }
        })
    }

    var viewerBasicPDFButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: ViewerPDFBasicContainer()
                .navigationBarTitle("Basic PDF Viewer")
            ) {
                Text("Launch Basic PDF Viewer")
            }
        })
    }

    var viewerPDFButton: some View {
        Button(action: {}, label: {
            NavigationLink(destination: ViewerPDFContainer()
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
