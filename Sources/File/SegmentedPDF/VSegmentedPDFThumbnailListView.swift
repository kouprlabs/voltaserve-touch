import PDFKit
import SwiftUI

struct VSegmentedPDFThumbnailListView: View {
    @ObservedObject var document: VSegmentedPDFDocument
    let pdfView: PDFView
    @State private var visibleIndices: Set<Int> = []
    @State private var isScrolling = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 16) {
                    ForEach(0 ..< document.totalPages, id: \.self) { index in
                    // Adjusted for 1-based indexing
                        VSegmentedPDFThumbnailView(index: index + 1, document: document, pdfView: pdfView)
                            .onAppear {
                            // Adjusted for 1-based indexing
                                visibleIndices.insert(index + 1)
                                loadThumbnailsIfNeeded()
                            }
                            // Provide an ID for scrolling
                            .id(index)
                    }
                }
                .padding(16)
                .onChange(of: document.currentPage) { currentPage, _ in
                    withAnimation {
                        proxy.scrollTo(currentPage - 1, anchor: .center)
                    }
                }
            }
        }
        .onChange(of: document.pdfDocument) {
            visibleIndices = []
            loadThumbnailsIfNeeded()
        }
        .onAppear {
            loadThumbnailsIfNeeded()
        }
    }

    private func loadThumbnailsIfNeeded() {
        // Load thumbnails sequentially
        let indicesToLoad = visibleIndices
            .filter { document.loadedThumbnails[$0] == nil }
            .sorted()

        if let firstIndex = indicesToLoad.first {
            document.loadThumbnail(for: firstIndex)
        }
    }
}
