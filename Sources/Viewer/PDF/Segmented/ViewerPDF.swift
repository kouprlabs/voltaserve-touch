import PDFKit
import SwiftUI

struct ViewerPDF: UIViewRepresentable {
    var store: ViewerPDFStore
    @Binding var showThumbnails: Bool

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
            if pdfView.document != pdfDocument {
                pdfView.document = pdfDocument
                pdfView.autoScales = true
                // Only set the scale factor if the document is changing
                pdfView.scaleFactor = pdfView.scaleFactorForSizeToFit
            }
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

        if showThumbnails {
            let thumbnailListView = ViewerPDFThumbnailListContainer(state: store, pdfView: pdfView)
            let hostingController = UIHostingController(rootView: thumbnailListView)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            hostingController.view.backgroundColor = .clear
            containerView.addSubview(hostingController.view)

            // Add constraints for Thumbnails, respecting safe area
            NSLayoutConstraint.activate([
                pdfView.bottomAnchor.constraint(equalTo: hostingController.view.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                // Use safeAreaLayoutGuide
                hostingController.view.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
                hostingController.view.heightAnchor.constraint(equalToConstant: 160)
            ])
        } else {
            NSLayoutConstraint.activate([
                // Use safeAreaLayoutGuide
                pdfView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }

    class Coordinator: NSObject {
        var pdfView: PDFView?
        var parent: ViewerPDF

        init(_ parent: ViewerPDF) {
            self.parent = parent
        }
    }
}

struct ViewerPDFContainer: View {
    @ObservedObject private var state = ViewerPDFStore(
        config: GlobalConstants.config,
        token: GlobalConstants.token
    )
    @State private var showThumbnails = true

    var body: some View {
        VStack {
            // Separate top part with loading spinner if needed
            ZStack {
                ViewerPDFPage(state: state)
                    .edgesIgnoringSafeArea(.all)
            }

            // Thumbnails view at bottom, always visible
            if showThumbnails {
                ViewerPDFThumbnailList(state: state, pdfView: PDFView())
                    .frame(height: 150)
                    .background(Color.white)
                    .transition(.move(edge: .bottom))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation {
                        showThumbnails.toggle()
                    }
                }, label: {
                    Label(
                        "Toggle Thumbnails",
                        systemImage: showThumbnails ? "rectangle.bottomhalf.filled" : "rectangle.split.1x2"
                    )
                })
            }
        }.onAppear {
            Task {
                await state.loadPDF()
            }
        }
    }
}
