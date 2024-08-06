import PDFKit
import SwiftUI

struct VPDFView: UIViewRepresentable {
    @ObservedObject var document: VPDFDocument
    @Binding var showThumbnails: Bool // Using Binding to alter the state from the parent view

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        // Create and configure the PDFView
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pdfView)

        context.coordinator.pdfView = pdfView

        updateLayout(containerView: containerView, context: context)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        print("Updating UIView with document: \(document.pdfDocument?.documentURL?.absoluteString ?? "nil")")
        guard let pdfView = context.coordinator.pdfView else { return }

        if let pdfDocument = document.pdfDocument {
            print("Setting PDF document to PDFView")
            pdfView.document = pdfDocument
        } else {
            print("No PDF document available to set")
        }

        // Update layout to reflect visibility changes
        updateLayout(containerView: uiView, context: context)
    }

    private func updateLayout(containerView: UIView, context: Context) {
        containerView.subviews.forEach { $0.removeFromSuperview() }

        guard let pdfView = context.coordinator.pdfView else { return }

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pdfView)

        // Add constraints for PDFView, respecting safe area
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor) // Use safeAreaLayoutGuide
        ])

        if showThumbnails {
            let thumbnailListView = VPDFThumbnailListViewContainer(document: document, pdfView: pdfView)
            let hostingController = UIHostingController(rootView: thumbnailListView)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear
            containerView.addSubview(hostingController.view)

            // Add constraints for Thumbnails, respecting safe area
            NSLayoutConstraint.activate([
                pdfView.bottomAnchor.constraint(equalTo: hostingController.view.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor), // Use safeAreaLayoutGuide
                hostingController.view.heightAnchor.constraint(equalToConstant: 200)
            ])
        } else {
            NSLayoutConstraint.activate([
                pdfView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor) // Use safeAreaLayoutGuide
            ])
        }
    }

    class Coordinator: NSObject {
        var pdfView: PDFView?
        var parent: VPDFView

        init(_ parent: VPDFView) {
            self.parent = parent
        }
    }
}

struct VPDFThumbnailListViewContainer: View {
    @ObservedObject var document: VPDFDocument
    var pdfView: PDFView

    var body: some View {
        if let pdfDocument = document.pdfDocument {
            VPDFThumbnailListView(document: pdfDocument, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}

struct VPDFViewContainer: View {
    @ObservedObject var document: VPDFDocument
    @State private var showThumbnails: Bool = true // State variable to track thumbnail visibility

    var body: some View {
        VStack {
            VPDFView(document: document, showThumbnails: $showThumbnails)
                .edgesIgnoringSafeArea(.all)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) { // Place the toolbar item at top right
                Button(action: {
                    showThumbnails.toggle()
                }) {
                    Label("Toggle Thumbnails", systemImage: showThumbnails ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
                }
            }
        }
    }
}
