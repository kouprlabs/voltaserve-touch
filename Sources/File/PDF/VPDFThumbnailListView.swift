import PDFKit
import SwiftUI

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
