import PDFKit
import SwiftUI

struct ViewerPDFBasic: UIViewRepresentable {
    var store: ViewerPDFBasicStore

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
        guard let pdfView = context.coordinator.pdfView else { return }

        if let pdfDocument = store.pdfDocument {
            pdfView.document = pdfDocument
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
            // Use safeAreaLayoutGuide
            pdfView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            // Use safeAreaLayoutGuide
            pdfView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    class Coordinator: NSObject {
        var pdfView: PDFView?
        var parent: ViewerPDFBasic

        init(_ parent: ViewerPDFBasic) {
            self.parent = parent
        }
    }
}

struct ViewerPDFBasicContainer: View {
    @ObservedObject var store = ViewerPDFBasicStore(
        config: GlobalConstants.config,
        token: GlobalConstants.token
    )

    var body: some View {
        VStack {
            if store.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                ViewerPDFBasic(store: store)
                    .edgesIgnoringSafeArea(.all)
            }
        }.onAppear {
            store.loadPDF()
        }
    }
}
