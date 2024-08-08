import PDFKit
import SwiftUI

struct VSegmentedPDFThumbnailListView: View {
    @ObservedObject var document: VSegmentedPDFDocument
    let pdfView: PDFView
    @State private var visibleIndices: Set<Int> = []
    @State private var isScrolling = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0 ..< document.totalPages, id: \.self) { index in
                    // Adjusted for 1-based indexing
                    VSegmentedPDFThumbnailView(index: index + 1, document: document, pdfView: pdfView)
                        .onAppear {
                            // Adjusted for 1-based indexing
                            visibleIndices.insert(index + 1)
                            loadThumbnailsIfNeeded()
                        }
                }
            }
            .padding(16)
        }
        .onChange(of: document.pdfDocument) {
            visibleIndices = []
            loadThumbnailsIfNeeded()
        }
        .onAppear {
            print("VPDFThumbnailListView appeared")
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
