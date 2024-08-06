import SwiftUI

struct PDFLauncher: View {
    @StateObject var document = VPDFDocument()

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button(action: {}) {
                    NavigationLink(destination: VPDFView(document: document)) {
                        Text("Launch PDF View")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .navigationTitle("PDF Launcher")
            .navigationBarTitleDisplayMode(.inline)  // Ensures inline title display
            .navigationBarItems(leading: EmptyView()) // Optional: remove back button
        }
        // Ensures it behaves like a single view, not split view
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            document.loadPDF()
        }
    }
}

struct PDFLauncher_Previews: PreviewProvider {
    static var previews: some View {
        PDFLauncher()
    }
}