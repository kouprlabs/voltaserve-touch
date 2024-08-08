import SwiftUI

struct Launcher: View {
    @EnvironmentObject private var v3dDocument: V3DDocument
    @EnvironmentObject private var mosaicDocument: MosaicDocument
    @EnvironmentObject private var vpdfDocument: VSegmentedPDFDocument

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                mosaicButton
                    .padding()
                    .navigationBarHidden(true)
                    .onAppear {
                        mosaicDocument.shuffleFileId()
                    }
                v3dButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        v3dDocument.shuffleFileId()
                    }
                vpdfButton
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        vpdfDocument.shuffleFileId()
                    }
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
            NavigationLink(destination: VSegmentedPDFViewContainer()
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
