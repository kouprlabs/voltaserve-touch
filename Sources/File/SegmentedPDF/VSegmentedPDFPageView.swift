import PDFKit
import SwiftUI

struct VSegmentedPDFPageView: UIViewRepresentable {
    @ObservedObject var document: VSegmentedPDFDocument

    func makeUIView(context: Context) -> UIView {
        print("Creating UIView...")
        let containerView = UIView()

        // Create and configure the PDFView
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
        print("Updating UIView with document: \(document.pdfDocument?.documentURL?.absoluteString ?? "nil")")

        guard let pdfView = context.coordinator.pdfView else { return }

        // Remove existing constraints before updating
        uiView.constraints.forEach { uiView.removeConstraint($0) }

        if let pdfDocument = document.pdfDocument {
            print("Setting PDF document to PDFView")
            pdfView.document = pdfDocument
            print("PDF document set. Number of pages: \(pdfDocument.pageCount)") // Check if content is there
        } else {
            print("No PDF document available to set")
        }

        // Update layout constraints
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: uiView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
        ])
        print("Constraints updated for PDFView: \(pdfView.constraints)")
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
            print("Swiped left")
            guard parent.document.currentPage < parent.document.totalPages else {
                print("Already at last page")
                return
            }
            parent.document.currentPage += 1
            parent.document.loadPage(at: parent.document.currentPage)
        }

        @objc func swipeRight() {
            print("Swiped right")
            guard parent.document.currentPage > 1 else {
                print("Already at first page")
                return
            }
            parent.document.currentPage -= 1
            parent.document.loadPage(at: parent.document.currentPage)
        }
    }
}
