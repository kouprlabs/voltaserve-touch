import PDFKit
import SwiftUI

struct ViewerPDFPageView: UIViewRepresentable {
    @ObservedObject var document: ViewerPDFDocument

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        /* Create and configure the PDFView */
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displaysAsBook = false
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal

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

        if let pdfDocument = document.pdfDocument {
            if pdfView.document != pdfDocument {
                pdfView.document = pdfDocument
                pdfView.autoScales = true
                // Force PDFView to fit width initially
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            }
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
        var parent: ViewerPDFPageView

        init(_ parent: ViewerPDFPageView) {
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
