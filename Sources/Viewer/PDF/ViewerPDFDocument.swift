import PDFKit
import SwiftUI

class ViewerPDFDocument: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var loadedThumbnails: [Int: UIImage] = [:]
    @Published var totalPages = 0
    @Published var currentPage = 1
    private var store: ViewerPDFStore
    private var idRandomizer = IdRandomizer(Constants.fileIds)

    // Number of pages to preload before and after the current page
    private let preloadBufferSize = 5

    private var fileId: String {
        idRandomizer.value
    }

    init(config: Config, token: Token) {
        store = ViewerPDFStore(config: config, token: token)
    }

    func loadPDF() {
        store.fetchFile(id: fileId) { file, error in
            if let file {
                if let pages = file.snapshot?.preview?.document?.pages {
                    DispatchQueue.main.async {
                        self.totalPages = pages
                        self.loadPage(at: self.currentPage)
                        self.preloadSurroundingPages(for: self.currentPage)
                    }
                }
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }

    func loadPage(at index: Int) {
        guard index > 0, index <= totalPages else { return }

        store.fetchSegmentedPage(id: fileId, index) { data, error in
            if let data {
                if let newDocument = PDFDocument(data: data) {
                    DispatchQueue.main.async {
                        self.pdfDocument = newDocument
                        self.currentPage = index
                        self.preloadSurroundingPages(for: index)
                    }
                }
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }

    func loadThumbnail(for index: Int) {
        guard index > 0, index <= totalPages else { return }
        guard loadedThumbnails[index] == nil else { return }

        store.fetchSegmentedThumbnail(id: fileId, index) { [weak self] data, error in
            guard let self else { return }
            if let data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.loadedThumbnails[index] = image
                    self.loadThumbnail(for: index + 1)
                }
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }

    private func isPreloaded(page index: Int) -> Bool {
        // Check if page is preloaded in the local cache.
        pdfDocument?.page(at: index - 1) != nil
    }

    private func preloadSurroundingPages(for index: Int) {
        let start = max(1, index - preloadBufferSize)
        let end = min(totalPages, index + preloadBufferSize)

        for pageNumber in start ... end where !isPreloaded(page: pageNumber) {
            store.fetchSegmentedPage(id: fileId, pageNumber) { data, error in
                // Preload pages silently without affecting loading state of main view.
                if let data, let tempDoc = PDFDocument(data: data) {
                    DispatchQueue.main.async {
                        if self.pdfDocument?.pageCount == 0 {
                            self.pdfDocument = PDFDocument()
                        }
                        // Ensure index is within bounds
                        let targetIndex = min(pageNumber - 1, (self.pdfDocument?.pageCount ?? 0))
                        if targetIndex >= 0, targetIndex < (self.pdfDocument?.pageCount ?? 0) {
                            self.pdfDocument?.insert(tempDoc.page(at: 0)!, at: targetIndex)
                        }
                    }
                } else if let error {
                    print(error.localizedDescription)
                }
            }
        }
    }

    func shuffleFileId() {
        pdfDocument = nil
        idRandomizer.shuffle()
        loadPDF()
    }

    private enum Constants {
        static let fileIds = [
            "MaARV6ZzvPLxZ"
        ]
    }
}
