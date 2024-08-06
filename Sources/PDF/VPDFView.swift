import PDFKit
import SwiftUI

struct VPDFView: UIViewRepresentable {
    @ObservedObject var document: VPDFDocument

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

        // Add thumbnail list using SwiftUI
        let thumbnailListView = VPDFThumbnailListViewContainer(document: document, pdfView: pdfView)
        let hostingController = UIHostingController(rootView: thumbnailListView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hostingController.view)

        // Add constraints for PDFView and Thumbnails
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: hostingController.view.topAnchor),

            hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            hostingController.view.heightAnchor.constraint(equalToConstant: 200)
        ])

        context.coordinator.pdfView = pdfView

        return containerView
    }

    func updateUIView(_: UIView, context: Context) {
        guard let pdfView = context.coordinator.pdfView else { return }

        if let pdfDocument = document.pdfDocument {
            pdfView.document = pdfDocument
        } else {
            print("Failed to load PDF document")
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
