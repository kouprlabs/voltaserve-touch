import PDFKit
import SwiftUI

struct ViewerPDFPage: UIViewRepresentable {
    @ObservedObject var vm: ViewerPDFViewModel

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

        if let pdfDocument = vm.pdfDocument {
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
            guard parent.vm.currentPage < parent.vm.totalPages else {
                return
            }
            parent.vm.currentPage += 1
            parent.vm.loadPage(at: parent.vm.currentPage)
        }

        @objc func swipeRight() {
            guard parent.vm.currentPage > 1 else { return }
            parent.vm.currentPage -= 1
            parent.vm.loadPage(at: parent.vm.currentPage)
        }
    }
}
