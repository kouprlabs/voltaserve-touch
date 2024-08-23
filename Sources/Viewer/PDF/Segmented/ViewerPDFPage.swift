import PDFKit
import SwiftUI

struct ViewerPDFPage: UIViewRepresentable {
    @ObservedObject var state: ViewerPDFStore

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

        if let pdfDocument = state.pdfDocument {
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
        var parent: ViewerPDFPage

        init(_ parent: ViewerPDFPage) {
            self.parent = parent
        }

        @objc func swipeLeft() {
            guard parent.state.currentPage < parent.state.totalPages else {
                return
            }
            parent.state.currentPage += 1
            Task {
                await parent.state.loadPage(at: parent.state.currentPage)
            }
        }

        @objc func swipeRight() {
            guard parent.state.currentPage > 1 else { return }
            parent.state.currentPage -= 1
            Task {
                await parent.state.loadPage(at: parent.state.currentPage)
            }
        }
    }
}
