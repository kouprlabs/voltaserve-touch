import PDFKit
import SwiftUI
import Combine

struct VSegmentedPDFThumbnailListView: View {
    @ObservedObject var document: VSegmentedPDFDocument
    let pdfView: PDFView
    @State private var visibleIndices: Set<Int> = []
    @State private var isScrolling = false

    @State private var scrollOffset: CGFloat = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width // Assuming the width of the viewport
    let thumbnailWidth: CGFloat = 100 // Width of each thumbnail
    let thumbnailSpacing: CGFloat = 16 // Spacing between thumbnails

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: thumbnailSpacing) {
                    ForEach(0 ..< document.totalPages, id: \.self) { index in
                        VSegmentedPDFThumbnailView(index: index + 1, document: document, pdfView: pdfView)
                        .onAppear {
                            visibleIndices.insert(index + 1)
                        }
                        // Provide an ID for scrolling
                        .id(index)
                    }
                }
                .padding(16)
                .onChange(of: document.currentPage) { _, currentPage in
                    withAnimation {
                        proxy.scrollTo(currentPage - 1, anchor: .center)
                    }
                }
            }
            .background(GeometryReader {
                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: -$0.frame(in: .named("scrollView")).origin.x)
            })
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                scrollOffset = value
            }
        }
        .onAppear {
            startThumbnailUpdateThread()
        }
        .onDisappear {
            stopThumbnailUpdateThread()
        }
    }

    private func startThumbnailUpdateThread() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
            .sink { _ in
                updateVisibleThumbnails()
            }
    }

    private func stopThumbnailUpdateThread() {
        timerCancellable?.cancel()
    }

    private func updateVisibleThumbnails() {
        DispatchQueue.global(qos: .background).async {
            let totalItemWidth = self.thumbnailWidth + self.thumbnailSpacing
            let firstIndex = max(0, Int(self.scrollOffset / totalItemWidth))
            let lastVisibleOffset = self.scrollOffset + self.screenWidth
            let lastIndex = min(self.document.totalPages - 1, Int(lastVisibleOffset / totalItemWidth))

            let start = max(0, firstIndex - 10)
            let end = min(self.document.totalPages, lastIndex + 10)

            let indicesToLoad = Set((start...end).map { $0 + 1 }.filter { self.document.loadedThumbnails[$0] == nil }).sorted()

            if !indicesToLoad.isEmpty {
                DispatchQueue.main.async {
                    for index in indicesToLoad {
                        self.document.loadThumbnail(for: index)
                    }
                }
            }

            // Offload thumbnails out of the visible range
            self.clearAllThumbnailsOutOfRange(firstIndex: firstIndex, lastIndex: lastIndex)
        }
    }

    private func clearAllThumbnailsOutOfRange(firstIndex: Int, lastIndex: Int) {
        DispatchQueue.main.async {
            let range = (firstIndex - 10)...(lastIndex + 10)
            for index in 1...self.document.totalPages {
                if !range.contains(index - 1) {
                    self.document.loadedThumbnails.removeValue(forKey: index)
                }
            }
        }
    }
}

// Preference key for scroll offset
struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}