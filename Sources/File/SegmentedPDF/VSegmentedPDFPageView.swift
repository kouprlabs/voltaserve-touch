import PDFKit
import SwiftUI

struct VSegmentedPDFPageView: UIViewRepresentable {
    @ObservedObject var document: VSegmentedPDFDocument

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        /* Create and configure the PDFView */
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pdfView)

        context.coordinator.pdfView = pdfView
        updateUIView(containerView, context: context)

        let swipeLeft = UISwipeGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.swipeLeft)
        )
        swipeLeft.direction = .left
        containerView.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(
            target: context.coordinator,
            action: #selector(context.coordinator.swipeRight)
        )
        swipeRight.direction = .right
        containerView.addGestureRecognizer(swipeRight)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let pdfView = context.coordinator.pdfView else { return }

        // Remove existing constraints before updating
        uiView.constraints.forEach { uiView.removeConstraint($0) }

        if let pdfDocument = document.pdfDocument {
            pdfView.document = pdfDocument
        }

        /* Update layout constraints */
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: uiView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
        ])
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var pdfView: PDFView?
        var parent: VSegmentedPDFPageView

        init(_ parent: VSegmentedPDFPageView) {
            self.parent = parent
        }

        @objc func swipeLeft() {
            guard parent.document.currentPage < parent.document.totalPages else {
                return
            }
            parent.document.currentPage += 1
            parent.document.loadPage(at: parent.document.currentPage)
        }

        @objc func swipeRight() {
            guard parent.document.currentPage > 1 else { return }
            parent.document.currentPage -= 1
            parent.document.loadPage(at: parent.document.currentPage)
        }
    }
}
