import PDFKit
import SwiftUI

struct VPDFViewContainer: View {
    @EnvironmentObject private var document: VPDFDocument
    @State private var showThumbnails = true

    var body: some View {
        VStack {
            if document.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    // Try to match the style .large of UIKit's UIActivityIndicatorView
                    .scaleEffect(1.85)
            } else {
                VPDFView(document: document, showThumbnails: $showThumbnails)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showThumbnails.toggle()
                }, label: {
                    Label(
                        "Toggle Thumbnails",
                        systemImage: showThumbnails ? "rectangle.bottomhalf.filled" : "rectangle.split.1x2"
                    )
                })
            }
        }.onAppear {
            document.loadPDF()
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
        if document.pdfDocument != nil {
            VPDFThumbnailListView(document: document, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}

struct VPDFThumbnailView: View {
    let index: Int
    @ObservedObject var document: VPDFDocument
    let pdfView: PDFView

    var body: some View {
        if let thumbnail = document.loadedThumbnails[index] {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                // Background to show when no image
                .background(Color.gray.opacity(0.2))
                .frame(width: 100, height: 150, alignment: .center)
                .onTapGesture {
                    if let page = document.pdfDocument?.page(at: index) {
                        pdfView.go(to: page)
                    }
                }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 100, height: 150, alignment: .center)
        }
    }
}

struct VPDFThumbnailListView: View {
    @ObservedObject var document: VPDFDocument
    let pdfView: PDFView
    @State private var visibleIndices: Set<Int> = []
    @State private var isScrolling = false

    private let chunkSize = 10
    private let debounceTime = DispatchTimeInterval.milliseconds(200)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< (document.pdfDocument?.pageCount ?? 0), id: \.self) { index in
                    VPDFThumbnailView(index: index, document: document, pdfView: pdfView)
                        .onAppear {
                            visibleIndices.insert(index)
                            loadThumbnailsDebounced()
                        }
                }
            }
            .padding(16)
        }
        .onChange(of: document.pdfDocument) {
            visibleIndices = []
            loadThumbnailsIfNeeded()
        }
    }

    private func loadThumbnailsDebounced() {
        isScrolling = true
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceTime) {
            if isScrolling {
                isScrolling = false
                loadThumbnailsIfNeeded()
            }
        }
    }

    private func loadThumbnailsIfNeeded() {
        let indicesToLoad = visibleIndices
            .filter { document.loadedThumbnails[$0] == nil }
            .prefix(chunkSize)

        // Move thumbnail loading to a background queue
        DispatchQueue.global(qos: .userInitiated).async {
            document.loadThumbnails(for: Array(indicesToLoad))
        }
    }
}
