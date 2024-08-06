import PDFKit
import SwiftUI

struct VPDFViewContainer: View {
    @ObservedObject private var document = VPDFDocument()
    @State private var showThumbnails: Bool = true

    init() {
        document.loadPDF()
    }

    var body: some View {
        VStack {
            VPDFView(document: document, showThumbnails: $showThumbnails)
                .edgesIgnoringSafeArea(.all)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showThumbnails.toggle()
                }, label: {
                    Label("Toggle Thumbnails", systemImage: showThumbnails ? "rectangle.bottomhalf.filled" : "rectangle.split.1x2")
                })
            }
        }
    }
}

struct VPDFView: UIViewRepresentable {
    @ObservedObject var document: VPDFDocument
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
            // Use safeAreaLayoutGuide
            pdfView.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor)
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

struct VPDFThumbnailView: View {
    let page: PDFPage
    let pdfView: PDFView

    var body: some View {
        let thumbnail = page.thumbnail(of: CGSize(width: 100, height: 150), for: .mediaBox)
        Image(uiImage: thumbnail)
            .resizable()
            .aspectRatio(contentMode: .fit)
            // Background to show when no image
            .background(Color.gray.opacity(0.2))
            .frame(width: 100, height: 150, alignment: .center)
            .onTapGesture {
                pdfView.go(to: page)
            }
    }
}

struct VPDFThumbnailListView: View {
    let document: PDFDocument
    let pdfView: PDFView

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< document.pageCount, id: \.self) { index in
                    if let page = document.page(at: index) {
                        VPDFThumbnailView(page: page, pdfView: pdfView)
                    } else {
                        Text("Error loading page")
                    }
                }
            }
            .padding(16)
        }
    }
}
