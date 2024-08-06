import SwiftUI

struct VPDFLauncher: View {
    @StateObject var document = VPDFDocument()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {}, label: {
                    NavigationLink(destination: VPDFView(document: document)) {
                        Text("Launch PDF View")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                })
                Spacer()
            }
            .navigationTitle("PDF Launcher")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: EmptyView())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            document.loadPDF()
        }
    }
}
