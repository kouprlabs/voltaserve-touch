import PDFKit
import SwiftUI

struct ViewerPDFBasic: View {
    @ObservedObject var store = ViewerPDFBasicStore()

    var body: some View {
        VStack {
            if store.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                ViewerPDFBasicRenderer(store: store)
            }
        }.onAppear {
            store.loadPDF()
        }
    }
}

struct ViewerPDFBasicRenderer: UIViewRepresentable {
    var store: ViewerPDFBasicStore

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

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

        updateLayout(containerView: uiView, context: context)
    }

    private func updateLayout(containerView: UIView, context: Context) {
        containerView.subviews.forEach { $0.removeFromSuperview() }

        guard let pdfView = context.coordinator.pdfView else { return }

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pdfView)

        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            pdfView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    class Coordinator: NSObject {
        var pdfView: PDFView?
        var parent: ViewerPDFBasicRenderer

        init(_ parent: ViewerPDFBasicRenderer) {
            self.parent = parent
        }
    }
}
