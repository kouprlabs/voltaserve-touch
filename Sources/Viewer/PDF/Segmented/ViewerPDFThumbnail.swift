import Combine
import PDFKit
import SwiftUI

struct ViewerPDFThumbnail: View {
    @ObservedObject var state: ViewerPDFStore

    let index: Int
    let pdfView: PDFView

    var body: some View {
        if let thumbnail = state.loadedThumbnails[index] {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 150, alignment: .center)
                .overlay {
                    Color.black.opacity(state.currentPage == index ? 0 : 0.4)
                }
                .clipped()
                .onTapGesture {
                    Task {
                        state.currentPage = index
                        await state.loadPage(at: index)
                    }
                }
        } else {
            Color.gray.opacity(0.2)
                .frame(width: 100, height: 150, alignment: .center)
        }
    }
}

struct ViewerPDFThumbnailList: View {
    @ObservedObject var state: ViewerPDFStore

    let pdfView: PDFView

    @State private var visibleIndices: Set<Int> = []
    @State private var isScrolling = false
    @State private var scrollOffset: CGFloat = 0
    @State private var timerCancellable: AnyCancellable?
    @State private var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                HStack(spacing: 0) {
                    ForEach(0 ..< state.totalPages, id: \.self) { index in
                        ViewerPDFThumbnail(state: state, index: index + 1, pdfView: pdfView)
                            .padding(.leading, Constants.thumbnailSpacing)
                            .padding(.bottom, Constants.thumbnailSpacing)
                            .onAppear {
                                visibleIndices.insert(index + 1)
                            }
                            .id(index)
                    }
                }
                .onChange(of: state.currentPage) { _, currentPage in
                    withAnimation {
                        proxy.scrollTo(currentPage - 1, anchor: .center)
                    }
                }
            }
            .background(GeometryReader {
                Color.clear.preference(
                    key: ScrollViewOffsetPreferenceKey.self,
                    value: -$0.frame(in: .named("scrollView")).origin.x
                )
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
            let totalItemWidth = Constants.thumbnailWidth + Constants.thumbnailSpacing
            let firstIndex = max(0, Int(scrollOffset / totalItemWidth))
            let lastVisibleOffset = scrollOffset + screenWidth
            let lastIndex = min(state.totalPages - 1, Int(lastVisibleOffset / totalItemWidth))

            let start = max(0, firstIndex - 10)
            let end = min(state.totalPages, lastIndex + 10)

            let indicesToLoad = Set((start ... end)
                .map { $0 + 1 }
                .filter { state.loadedThumbnails[$0] == nil })
                .sorted()

            if !indicesToLoad.isEmpty {
                Task { @MainActor in
                    for index in indicesToLoad {
                        await state.loadThumbnail(for: index)
                    }
                }
            }

            clearAllThumbnailsOutOfRange(firstIndex: firstIndex, lastIndex: lastIndex)
        }
    }

    private func clearAllThumbnailsOutOfRange(firstIndex: Int, lastIndex: Int) {
        DispatchQueue.main.async {
            var lowerBound = firstIndex - 10
            if lowerBound < 0 {
                lowerBound = 0
            }
            let upperBound = lastIndex + 10
            if lowerBound <= upperBound, state.totalPages >= 1 {
                for index in 1 ... state.totalPages where !(lowerBound ... upperBound).contains(index - 1) {
                    state.loadedThumbnails.removeValue(forKey: index)
                }
            }
        }
    }

    private enum Constants {
        static let thumbnailWidth: CGFloat = 100
        static let thumbnailSpacing: CGFloat = 16
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct ViewerPDFThumbnailListContainer: View {
    @ObservedObject var state: ViewerPDFStore
    var pdfView: PDFView

    var body: some View {
        if state.pdfDocument != nil {
            ViewerPDFThumbnailList(state: state, pdfView: pdfView)
        } else {
            EmptyView()
        }
    }
}
